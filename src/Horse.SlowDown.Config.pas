unit Horse.SlowDown.Config;

interface

uses
  Store.Intf, Store.Lib.Memory,
  System.SysUtils, System.SyncObjs;

type
  TSlowDownConfig = record
    Id: string;
    DelayAfter: Integer;
    DelayMs: Integer;
    MaxDelayMs: Integer;
    Timeout: Integer;
    Store: IStore;
  end;

  TSlowDownManager = class
  private
    FDictionary: TMemoryDictionary<TSlowDownConfig>;
    FConfig: TSlowDownConfig;

    procedure SetConfig(const AConfig: TSlowDownConfig);

    class var FInstance: TSlowDownManager;
    class var CriticalSection: TCriticalSection;
  public
    constructor Create();
    destructor Destroy; override;

    function GetDictionary: TMemoryDictionary<TSlowDownConfig>;
    procedure Save;

    property Config: TSlowDownConfig read FConfig write FConfig;

    class function New(const AConfig: TSlowDownConfig): TSlowDownManager;
    class destructor UnInitialize;
  end;

implementation

{ TSlowDownManager }

constructor TSlowDownManager.Create();
begin
  if Assigned(FInstance) then
    raise Exception.Create('The SlowDownManager instance has already been created!');

  FDictionary := TMemoryDictionary<TSlowDownConfig>.Create;
end;

destructor TSlowDownManager.Destroy;
begin
  FreeAndNil(FDictionary);
end;

class function TSlowDownManager.New(const AConfig: TSlowDownConfig): TSlowDownManager;
begin
  if not(Assigned(FInstance)) then
    FInstance := TSlowDownManager.Create();

  FInstance.SetConfig(AConfig);

  Result := FInstance;
end;

class destructor TSlowDownManager.UnInitialize;
begin
  if Assigned(FInstance) then
    FreeAndNil(FInstance);
end;

procedure TSlowDownManager.Save;
begin
  CriticalSection.Enter;
  try
    FDictionary.AddOrSetValue(Config.Id, Config);
  finally
    CriticalSection.Leave;
  end;
end;

function TSlowDownManager.GetDictionary: TMemoryDictionary<TSlowDownConfig>;
begin
  Result := FDictionary;
end;

procedure TSlowDownManager.SetConfig(const AConfig: TSlowDownConfig);
var
  LConfig: TSlowDownConfig;
begin
  CriticalSection.Enter;
  try
    if not(FDictionary.TryGetValue(AConfig.Id, LConfig)) then
    begin
      FDictionary.Add(AConfig.Id, AConfig);
      LConfig := AConfig;
    end;
  finally
    CriticalSection.Leave;
  end;

  FConfig := LConfig;
end;

initialization

TSlowDownManager.CriticalSection := TCriticalSection.Create;

finalization

FreeAndNil(TSlowDownManager.CriticalSection);

end.
