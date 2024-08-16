import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/colors.dart';
import '../utils/functions/image_format.dart';
import '../utils/text.dart';
import '../widgets/meaasge_widget.dart';
import '../widgets/show_error_message.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

class ChatPAge extends StatefulWidget {
  const ChatPAge({super.key, required this.apiKey});

  final String apiKey;

  @override
  State<ChatPAge> createState() => _ChatPAgeState();
}

class _ChatPAgeState extends State<ChatPAge> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: SvgPicture.asset(
          'assets/images/Gemini.svg',
          alignment: Alignment.center,
          width: 110,
        ),
        centerTitle: true,
      ),
      body: ChatBody(apiKey: widget.apiKey),
    );
  }
}

class ChatBody extends StatefulWidget {
  const ChatBody({super.key, required this.apiKey});

  final String apiKey;
  @override
  State<ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends State<ChatBody> {
  late final GenerativeModel _generativeModel;
  late final ChatSession _chatSession;
  final ScrollController _scrollController = ScrollController();
  bool _loading = false;
  final FocusNode _textField = FocusNode();
  final TextEditingController _txtController = TextEditingController();
  final List<({Image? image, String? txt, bool isUserMsg})> _content = [];

  @override
  void initState() {
    _generativeModel = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: widget.apiKey,
    );
    _chatSession = _generativeModel.startChat();
    super.initState();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        curve: Curves.easeInCubic,
        duration: const Duration(microseconds: 750),
        _scrollController.position.maxScrollExtent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: widget.apiKey.isNotEmpty
                ? ListView.builder(
                    controller: _scrollController,
                    itemCount: _content.length,
                    itemBuilder: (context, index) {
                      final content = _content[index];
                      return MessageWidget(
                        txt: content.txt,
                        isUserMsg: content.isUserMsg,
                        image: content.image,
                      );
                    },
                  )
                : ListView(
                    children: [
                      Center(
                        child: Text(
                          'NO API KEY FOUND!',
                          style: title2Bold,
                        ),
                      )
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onSubmitted: _sendMessage,
                    autofocus: true,
                    focusNode: _textField,
                    controller: _txtController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(15),
                      hintText: 'Enter Prompt Here..',
                      hintStyle: title2Bold.copyWith(
                        color: AppColors.white.withOpacity(0.7),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: AppColors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: AppColors.grey),
                      ),
                      fillColor: AppColors.grey,
                      filled: true,
                    ),
                    cursorColor: AppColors.white,
                  ),
                ),
                const SizedBox.square(
                  dimension: 15,
                ),
                IconButton(
                  onPressed: () {
                    _pickImage();
                  },
                  icon: const Icon(
                    Icons.image,
                  ),
                ),
                if (!_loading)
                  IconButton(
                    onPressed: () => _sendMessage(_txtController.text),
                    icon: Icon(
                      Icons.send,
                      color: AppColors.blue,
                    ),
                  )
                else
                  const Center(
                      child: CircularProgressIndicator(
                    color: AppColors.grey,
                  ))
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(String message) async {
    setState(
      () {
        _loading = true;
      },
    );
    try {
      _content.add((image: null, txt: message, isUserMsg: true));

      final GenerateContentResponse response = await _chatSession.sendMessage(
        Content.text(message),
      );

      final txt = response.text;
      _content.add((image: null, txt: txt, isUserMsg: false));

      if (txt == null) {
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) {
            return const ShowErrorMessage(
              msg: 'No Response Found!',
            );
          },
        );
      } else {
        setState(() {
          _loading = false;
          _scrollDown();
        });
      }
    } catch (e) {
      ShowErrorMessage(msg: e.toString());
      setState(() {
        _loading = false;
      });
    } finally {
      _txtController.clear();
      _textField.requestFocus();
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker pickImage = ImagePicker();
    final XFile? image = await pickImage.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _loading = true;
      });
      try {
        final bytes = await image.readAsBytes();
        final imageFormat = await determineImageFormat(bytes);
        final content = [
          Content.multi(
            [
              TextPart(_txtController.text),
              DataPart(imageFormat, bytes),
            ],
          ),
        ];
        _content.add(
          (
            txt: _txtController.text,
            image: Image.memory(bytes),
            isUserMsg: true,
          ),
        );

        GenerateContentResponse response =
            await _generativeModel.generateContent(content);

        var text = response.text;

        _content.add((
          image: null,
          txt: text,
          isUserMsg: false,
        ));

        if (text == null) {
          showDialog(
            // ignore: use_build_context_synchronously
            context: context,
            builder: (context) {
              return const ShowErrorMessage(
                msg: 'No Response Found!',
              );
            },
          );
        } else {
          setState(() {
            _loading = false;
            _scrollDown();
          });
        }
      } catch (e) {
        ShowErrorMessage(msg: e.toString());
        setState(() {
          _loading = false;
        });
      } finally {
        _txtController.clear();
        _textField.requestFocus();
      }
    }
  }
}
