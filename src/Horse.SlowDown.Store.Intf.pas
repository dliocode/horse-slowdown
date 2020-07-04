unit Horse.SlowDown.Store.Intf;

interface

type
  TSlowDownStoreCallback = record
    Current: Integer;
    ResetTime: TDateTime;
  end;

  ISlowDownStore = interface
    ['{75A8E917-85D7-40D2-874A-70E86D3D5EF3}']
    function Incr(AKey: string): TSlowDownStoreCallback;
    procedure Decrement(AKey: string);
    procedure ResetAll();
  end;

implementation

end.
