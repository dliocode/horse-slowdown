program Model2;

uses Horse, Horse.SlowDown;

var
  App: THorse;
begin
  App := THorse.Create(9000);

  App.Get('/ping', THorseSlowDown.New('ping').limit,
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('pong');
    end);

  App.Get('/book', THorseSlowDown.New('book').limit,
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('The book!');
    end);

  App.Get('/login', THorseSlowDown.New('login',10,500,60).limit,
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('My Login with Request Max of 10 every 60 seconds!');
    end);

  App.Start;
end.
