unit Horse.SlowDown;

interface

uses
  Horse,
  Horse.SlowDown.Config, Horse.SlowDown.Utils,
  Store.Intf, Store.Memory,
  System.SysUtils, System.Math, System.SyncObjs, System.Classes,
  Web.HTTPApp;

const
  DEFAULT_DELAYAFTER = 60;
  DEFAULT_DELAYMS = 1000;
  DEFAULT_TIMEOUT = 60;

type
  TSlowDownConfig = Horse.SlowDown.Config.TSlowDownConfig;

  THorseSlowDown = class
  private
    class var CriticalSection: TCriticalSection;
  public
    class function New(const AConfig: TSlowDownConfig): THorseCallback; overload;
    class function New(const AId: string = ''; const ADelayAfter: Integer = DEFAULT_DELAYAFTER; const ADelayMs: Integer = DEFAULT_DELAYMS; const ATimeout: Integer = DEFAULT_TIMEOUT; const AStore: IStore = nil): THorseCallback; overload;
  end;

implementation

{ THorseSlowDown }

class function THorseSlowDown.New(const AConfig: TSlowDownConfig): THorseCallback;
var
  FManagerConfig: TSlowDownManager;
  LConfig: TSlowDownConfig;
begin
  FManagerConfig := TSlowDownManager.New(AConfig);

  if not(Assigned(FManagerConfig.Config.Store)) then
  begin
    LConfig := FManagerConfig.Config;
    LConfig.Store := TMemoryStore.New();

    FManagerConfig.Config := LConfig;
  end;

  FManagerConfig.Config.Store.SetTimeout(FManagerConfig.Config.Timeout);

  Result := procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      LManagerConfig: TSlowDownManager;
      LStoreCallback: TStoreCallback;
      LKey: string;
      LTimeSleep: Int64;
    begin
      CriticalSection.Enter;
      try
        LManagerConfig := TSlowDownManager.New(AConfig);
      finally
        CriticalSection.Leave;
      end;

      LKey := 'SD:' + LManagerConfig.Config.Id + ':' + ClientIP(Req);

      LStoreCallback := LManagerConfig.Config.Store.Incr(LKey);

      if (LStoreCallback.Current > LManagerConfig.Config.DelayAfter) then
      begin
        LTimeSleep := LManagerConfig.Config.DelayMs * (LStoreCallback.Current - LManagerConfig.Config.DelayAfter);

        if (LManagerConfig.Config.MaxDelayMs > 0) then
          if (LTimeSleep > LManagerConfig.Config.MaxDelayMs) then
            LTimeSleep := LManagerConfig.Config.MaxDelayMs;

        TThread.Sleep(LTimeSleep);
      end;

      try
        Next;
      finally
        LManagerConfig.Save;
      end;
    end;
end;

class function THorseSlowDown.New(const AId: string = ''; const ADelayAfter: Integer = DEFAULT_DELAYAFTER; const ADelayMs: Integer = DEFAULT_DELAYMS; const ATimeout: Integer = DEFAULT_TIMEOUT; const AStore: IStore = nil): THorseCallback;
var
  LConfig: TSlowDownConfig;
begin
  LConfig.Id := AId;
  LConfig.DelayAfter := ADelayAfter;
  LConfig.DelayMs := ADelayMs;
  LConfig.MaxDelayMs := 0;
  LConfig.Timeout := ATimeout;
  LConfig.Store := AStore;

  Result := New(LConfig);
end;

initialization

THorseSlowDown.CriticalSection := TCriticalSection.Create;

finalization

FreeAndNil(THorseSlowDown.CriticalSection);

end.
