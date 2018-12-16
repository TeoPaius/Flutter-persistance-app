class Run{
    int     duration;
    String  date;
    int  length;
    String  id;

    Run(this.duration, this.date, this.length);

    Run.fromJson(Map<String, dynamic> json)
        :   duration = json['duration'],
            date = json['date'],
            length = json['length'],
            id = json['id'];
    Map<String, dynamic> toJson() =>
        {
          'duration': duration,
          'length': length,
          'date': date,
          'id': id
        };


}