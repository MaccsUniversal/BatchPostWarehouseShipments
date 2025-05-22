codeunit 50104 "Hide Post Shpt. Dialog - WBP"
{
    EventSubscriberInstance = Manual;

    var
        BatchPost: Boolean;
        ShipAndInvoice: Boolean;

    procedure SetParameters(var BatchPost: Boolean; var ShipAndInvoice: Boolean)
    begin
        this.BatchPost := BatchPost;
        this.ShipAndInvoice := ShipAndInvoice;
    end;

    procedure GetParameters() Result: array[2] of Boolean
    begin
        Result[0] := this.BatchPost;
        Result[1] := this.ShipAndInvoice;
        exit(Result);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Shipment (Yes/No)", OnBeforeConfirmWhseShipmentPost, '', true, true)]
    local procedure SetParameterOnBeforeConfirmWhseShipmentPost(var HideDialog: Boolean; var Invoice: Boolean; var IsPosted: Boolean)
    var
        UserSetupManagement: Codeunit "User Setup Management";
    begin
        if BatchPost then begin
            UserSetupManagement.GetSalesInvoicePostingPolicy(HideDialog, Invoice);
            HideDialog := true;
            Invoice := ShipAndInvoice;
            IsPosted := false;
        end;

    end;
}