codeunit 50105 "Get Result Message - WBP"
{
    EventSubscriberInstance = Manual;

    var
        ShipmentCount: Integer;
        BatchPost: Boolean;
        TotalShipments: Integer;

    procedure SetParameters(var BatchPost: Boolean; var TotalShipment: Integer)
    begin
        this.BatchPost := BatchPost;
        this.TotalShipments := TotalShipment;
    end;

    procedure SetShipmentCount(var ShipmentCount: Integer)
    begin
        this.ShipmentCount := ShipmentCount;
    end;

    //Sends Result back in Text format for forward conversion.
    //Use OnBeforeGetResultMessageParameters to retreive actual variable Data Types.
    //Call in repeat block for updated ShipmentCount Value.
    procedure GetParameters() Result: array[3] of Text
    var
        Numbers: array[2] of Integer;
        OK: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        Numbers[0] := this.ShipmentCount;
        Numbers[1] := this.TotalShipments;
        OK := this.BatchPost;

        OnBeforeGetResultMessageParameters(Numbers, OK, IsHandled);
        if IsHandled then
            exit;

        Result[0] := Format(this.ShipmentCount);
        Result[1] := Format(this.TotalShipments);
        Result[2] := Format(this.BatchPost);
        exit(Result);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Shipment", OnGetResultMessageOnBeforeShowMessage, '', true, true)]
    local procedure OnGetBatchResultMessageOnBeforeShowMessage(var CounterSourceDocOK: Integer; var CounterSourceDocTotal: Integer; var IsHandled: Boolean)
    begin
        IsHandled := true;
        if this.ShipmentCount = TotalShipments then begin
            CounterSourceDocOK := this.ShipmentCount;
            CounterSourceDocTotal := this.TotalShipments;
            IsHandled := false;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetResultMessageParameters(var Numbers: array[2] of Integer; var OK: Boolean; var IsHandled: Boolean)
    begin
    end;
}