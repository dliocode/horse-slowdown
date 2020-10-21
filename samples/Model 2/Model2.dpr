program Model2;

uses Horse, Horse.SlowDown;

begin
  THorse.Get('/ping', THorseSlowDown.New('ping').limit,
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('pong');
    end)

  .Get('/book', THorseSlowDown.New('book').limit,
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('The book!');
    end)

  .Get('/login', THorseSlowDown.New('login',10,500,60).limit,
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('My Login with Request Max of 10 every 60 seconds!');
    end);

  THorse.Listen(9000);
end.
