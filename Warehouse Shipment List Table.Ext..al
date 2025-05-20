pageextension 50100 "Warehouse Shipment List MOO" extends "Warehouse Shipment List"
{
    PromotedActionCategories = 'Post Batch';

    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here

        addlast(Posting)
        {

            action("Post Batch")
            {
                ApplicationArea = All;
                Caption = 'Post &Batch';
                Image = PostBatch;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    RecRef: RecordRef;
                    SelectionFilterManagement: Codeunit SelectionFilterManagement;
                    WarehouseShipmentHeader: Record "Warehouse Shipment Header";
                    BatchPostWhseShipDoc: Report "Batch Post Warehouse Shpt Doc.";
                begin
                    CurrPage.SetSelectionFilter(WarehouseShipmentHeader);
                    RecRef.GetTable(WarehouseShipmentHeader);
                    WarehouseShipmentHeader.SetFilter("No.", SelectionFilterManagement.GetSelectionFilter(RecRef, Rec.FieldNo("No.")));
                    Report.RunModal(Report::"Batch Post Warehouse Shpt Doc.", true, false, WarehouseShipmentHeader);
                    CurrPage.Update(false);
                end;
            }
        }
    }
}