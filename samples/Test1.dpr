program Test1;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Horse.Commons in 'modules\horse\src\Horse.Commons.pas',
  Horse.Constants in 'modules\horse\src\Horse.Constants.pas',
  Horse.Core in 'modules\horse\src\Horse.Core.pas',
  Horse.Core.Route.Intf in 'modules\horse\src\Horse.Core.Route.Intf.pas',
  Horse.Core.Route in 'modules\horse\src\Horse.Core.Route.pas',
  Horse.Exception in 'modules\horse\src\Horse.Exception.pas',
  Horse.HTTP in 'modules\horse\src\Horse.HTTP.pas',
  Horse.ISAPI in 'modules\horse\src\Horse.ISAPI.pas',
  Horse in 'modules\horse\src\Horse.pas',
  Horse.Router in 'modules\horse\src\Horse.Router.pas',
  Horse.WebModule in 'modules\horse\src\Horse.WebModule.pas' {HorseWebModule: TWebModule},
  Horse.SlowDown.Config in '..\src\Horse.SlowDown.Config.pas',
  Horse.SlowDown.Memory in '..\src\Horse.SlowDown.Memory.pas',
  Horse.SlowDown in '..\src\Horse.SlowDown.pas',
  Horse.SlowDown.Store.Intf in '..\src\Horse.SlowDown.Store.Intf.pas',
  Horse.SlowDown.Store.Memory in '..\src\Horse.SlowDown.Store.Memory.pas',
  Horse.SlowDown.Utils in '..\src\Horse.SlowDown.Utils.pas';

var
  App: THorse;
begin
  App := THorse.Create(9000);

  App.Get('/login', THorseSlowDown.New('login',3,1000,60).limit,
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('My Login com SlowDown - With 3 Request after SlowDown!');
    end);

  App.Start;
end.
