class Money {
  int id;
  String amount;
  String desc;
  int income;
  String date;

  // konstruktor versi 1
  Money(this.amount, this.desc, this.income, this.date);

  // konstruktor versi 2: konversi dari Map ke Contact
  Money.fromMap(Map<String, dynamic> map) {
    this.id 		= map['id'];
    this.amount = map['amount'];
    this.desc 	= map['desc'];
    this.income = map['income'];
    this.date 	= map['date'];
  }
  //getter dan setter (mengambil dan mengisi data kedalam object)
  // getter
  int get _id => id;
  String get _amount => amount;
  String get _desc => desc;
  int get _income => income;
  String get _date => date;

  // setter
  set _id(int value){
    id = value;
  }

  set _amount(String value) {
    amount = value;
  }

  set _desc(String value) {
    desc = value;
  }

  set _income(int value) {
  	income = value;
  }

  set _date(String value) {
  	date = value;
  }


  // konversi dari Money ke Map
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['id'] = this.id;
    map['amount'] = amount;
    map['desc'] = desc;
    map['income'] = income;
    map['date'] = date;
    return map;
  }
}