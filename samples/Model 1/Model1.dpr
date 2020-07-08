program Model1;

uses Horse, Horse.SlowDown;

var
  App: THorse;
begin
  App := THorse.Create(9000);

  App.Use(THorseSlowDown.New().Limit);

  App.Get('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('pong');
    end);

  App.Start;
end.
