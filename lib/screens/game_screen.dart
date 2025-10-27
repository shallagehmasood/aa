import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/card_model.dart';
import '../widgets/memory_card.dart';

class GameScreen extends StatefulWidget {
  final int pairCount;
  GameScreen({required this.pairCount});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<String> players = [
    "لیونل مسی", "کریستیانو رونالدو", "نیمار", "کیلیان ام‌باپه", "روبرت لواندوفسکی",
    "کوین دی‌بروینه", "محمد صلاح", "هری کین", "کریم بنزما", "ارلینگ هالند",
    "لوکا مودریچ", "ویرجیل فن‌دایک", "سادیو مانه", "سون هیونگ‌مین", "زلاتان ابراهیموویچ",
    "آنتوان گریزمان", "وینیسیوس جونیور", "جود بلینگهام", "پدری", "گاوی",
    "تونی کروس", "جاشوا کیمیچ", "کاسمیرو", "برونو فرناندز", "ژائو فلیکس",
    "فیل فودن", "مارکوس رشفورد", "بوکایو ساکا", "جک گریلیش", "ریاض محرز",
    "فرنکی دی‌یونگ", "انسو فاتی", "دکلان رایس", "میسون مانت", "تیاگو آلکانتارا",
    "رافائل واران", "سرخیو راموس", "جرارد پیکه", "جوردی آلبا", "ترنت الکساندر-آرنولد",
    "اندرو رابرتسون", "کایل واکر", "اشرف حکیمی", "تئو هرناندز", "مارکینیوش",
    "ادر میلیتائو", "آلیسون بکر", "تیبو کورتوا", "ادرسون", "مانوئل نویر",
    "جان‌لوئیجی دوناروما", "کیلور ناواس", "داوید دخیا", "تر اشتگن", "یان اوبلاک",
    "آنخل دی‌ماریا", "پائولو دیبالا", "لائوتارو مارتینس", "روملو لوکاکو", "ادینسون کاوانی",
    "لوئیس سوارز", "خامس رودریگز", "کریستین پولیشیچ", "وستون مک‌کنی", "آلفونسو دیویس",
    "هروینگ لوزانو", "تاکومی مینامینو", "شینجی کاگاوا", "مهدی طارمی", "سردار آزمون",
    "علی دایی", "سالم الدوسری", "یاسین بونو", "حکیم زیاش", "اشرف بنشرقی",
    "ویلفرید زاها", "اوبامیانگ", "کالیدو کولیبالی", "ویکتور اوسیمهن", "آندره اونانا",
    "ایوان پریشیچ", "مانژوکیچ", "کریستین اریکسن", "مارتین اودگارد", "هنریک مخیتاریان",
    "میرالم پیانیچ", "ادین ژکو", "دوشان ولاهوویچ", "سرگئی میلینکوویچ ساویچ", "الکساندر میتروویچ",
    "چیرو ایموبیله", "لورنزو اینسینیه", "فدریکو کیه‌زا", "مارکو وراتی", "لئوناردو بونوچی",
    "جورجو کیه‌لینی", "تیاگو سیلوا", "رودریگو", "رافینیا", "گابریل ژسوس", "ریچارلیسون"
  ];

  List<CardModel> cards = [];
  List<int> flippedIndexes = [];
  int moves = 0;
  int seconds = 0;
  int? bestMoves;
  int? bestTime;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    loadBestStats();
    startGame();
  }

  void loadBestStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bestMoves = prefs.getInt('bestMoves_${widget.pairCount}');
      bestTime = prefs.getInt('bestTime_${widget.pairCount}');
    });
  }

  void startGame() {
    final selected = [...players]..shuffle();
    final deck = [...selected.take(widget.pairCount), ...selected.take(widget.pairCount)]..shuffle();
    cards = deck.map((name) => CardModel(title: name)).toList();
    moves = 0;
    seconds = 0;
    flippedIndexes.clear();
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() => seconds++);
    });
    setState(() {});
  }

  void checkForWin() async {
    if (cards.every((c) => c.isMatched)) {
      timer?.cancel();
      final prefs = await SharedPreferences.getInstance();
      if (bestMoves == null || moves < bestMoves!) {
        await prefs.setInt('bestMoves_${widget.pairCount}', moves);
        bestMoves = moves;
      }
      if (bestTime == null || seconds < bestTime!) {
        await prefs.setInt('bestTime_${widget.pairCount}', seconds);
        bestTime = seconds;
      }
      setState(() {});
    }
  }

  void onCardTap(int index) {
    if (cards[index].isFlipped || cards[index].isMatched || flippedIndexes.length == 2) return;
    setState(() {
      cards[index].isFlipped = true;
      flippedIndexes.add(index);
    });
    if (flippedIndexes.length == 2) {
      moves++;
      final i1 = flippedIndexes[0];
      final i2 = flippedIndexes[1];
      if (cards[i1].title == cards[i2].title) {
        setState(() {
          cards[i1].isMatched = true;
          cards[i2].isMatched = true;
          flippedIndexes.clear();
        });
        checkForWin();
      } else {
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            cards[i1].isFlipped = false;
            cards[i2].isFlipped = false;
            flippedIndexes.clear();
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final matchedCount = cards.where((c) => c.isMatched).length;
    final isFinished = matchedCount == cards.length;

    return Scaffold(
      appBar: AppBar(title: Text('🎯 بازی حافظه فوتبالی')),
      body: Column(
        children: [
          SizedBox(height: 10),
          Text('حرکت‌ها: $moves   ⏱️ زمان: $seconds ثانیه'),
          if (bestMoves != null || bestTime != null)
            Text('🏆 رکورد: ${bestMoves ?? "-"} حرکت، ${bestTime ?? "-"} ثانیه'),
          if (isFinished) Text('🎉 بازی تمام شد!', style: TextStyle(color: Colors.green)),
          ElevatedButton(onPressed: startGame, child: Text('🔁 شروع دوباره')),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: cards.length,
              itemBuilder: (_, i) => MemoryCard(card: cards[i], onTap: () => onCardTap(i)),
            ),
          ),
        ],
      ),
    );
  }
}
