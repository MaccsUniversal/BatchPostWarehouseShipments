
codeunit 50100 "Whse.-Batch Post Shipment"
{
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
        BindSubscription(SkipTestPostingDate);
        BindSubscription(HidePostShptDialog);
        BindSubscription(GetResultMessage);
        SkipTestPostingDate.SetParameter(BatchPost);
        HidePostShptDialog.SetParameters(BatchPost, ShipAndInvoice);
        GetResultMessage.SetParameters(BatchPost, TotalShipments);
        if not BatchPost then
            Error(ErrorInfo.Create(Text000));

        PostShipment(WhseShptHdr);
        UnbindSubscription(SkipTestPostingDate);
        UnbindSubscription(HidePostShptDialog);
        UnbindSubscription(GetResultMessage);
    end;

    var
        ShipAndInvoice: Boolean;
        PostingDate: Date;
        BatchPost: Boolean;
        ShipmentCount: Integer;
        TotalShipments: Integer;
        WhseShptHdr: Record "Warehouse Shipment Header";
        Text000: Label 'Batch Post is not set to true. Please set BatchPost parameter to true before running the Report.';
        Text001: Label 'The Posting Date for each Warehouse Shipment in this batch have not been updated. Are you sure you want to continue?';
        SkipTestPostingDate: Codeunit "Skip Test Posting Date - WBP";
        HidePostShptDialog: Codeunit "Hide Post Shpt. Dialog - WBP";
        GetResultMessage: Codeunit "Get Result Message - WBP";

    procedure SetParameters(BatchPost: Boolean; var ShipAndInvoice: Boolean; var PostingDate: Date)
    begin
        this.BatchPost := BatchPost;
        this.ShipAndInvoice := ShipAndInvoice;
        this.PostingDate := PostingDate;
    end;

    procedure SetWhseShptHeader(var WhseShptHdr: Record "Warehouse Shipment Header")
    var
        ContinueToPostShipments: Boolean;
    begin
        TotalShipments := WhseShptHdr.Count();
        UpdateShipmentPostingDates(WhseShptHdr, PostingDate);
    end;

    local procedure UpdateShipmentPostingDates(var WarehouseShipmentHeader: Record "Warehouse Shipment Header"; var PostingDate: Date): Boolean
    var
        IsHandled: Boolean;
        Result: Boolean;
        Count: Integer;
    begin
        IsHandled := false;
        Result := true;

        OnBeforeUpdateShipmentPostingDate(IsHandled, Result);

        if IsHandled then
            exit(Result);

        WarehouseShipmentHeader.FindSet();
        repeat
            WarehouseShipmentHeader."Posting Date" := PostingDate;
            if WarehouseShipmentHeader.Modify() then
                Count += 1;
        until WarehouseShipmentHeader.Next <= 0;

        if Count = WarehouseShipmentHeader.Count() then
            Result := true;

        OnAfterUpdateShipmentPostingDates(WarehouseShipmentHeader);
        WhseShptHdr.Copy(WarehouseShipmentHeader);
        exit(Result);
    end;

    local procedure PostShipment(var WhseShptHeader: Record "Warehouse Shipment Header")
    var
        WhseShptLine: Record "Warehouse Shipment Line";
        WhsePostShipmentYesNo: Codeunit "Whse.-Post Shipment (Yes/No)";
    begin
        BindSubscription(this);
        WhseShptHeader.FindSet();
        ShipmentCount := 0;
        repeat
            ShipmentCount += 1;
            GetResultMessage.SetShipmentCount(ShipmentCount);
            GetLinesForRec(WhseShptLine, WhseShptHeader);
            WhsePostShipmentYesNo.Run(WhseShptLine);
        until WhseShptHeader.Next() <= 0;
        UnbindSubscription(this);
    end;

    local procedure GetLinesForRec(var WhseShptLine: Record "Warehouse Shipment Line"; var WhseShptHeader: Record "Warehouse Shipment Header")
    begin
        WhseShptLine.SetRange("No.", WhseShptHeader."No.");
        WhseShptLine.FindSet();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateShipmentPostingDate(var IsHandled: Boolean; var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateShipmentPostingDates(var WhseShptHdr: Record "Warehouse Shipment Header")
    begin
    end;

}