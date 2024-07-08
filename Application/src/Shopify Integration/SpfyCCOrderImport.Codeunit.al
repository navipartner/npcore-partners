#if not BC17
codeunit 6184806 "NPR Spfy C&C Order - Import"
{
    Access = Internal;
    TableNo = "NPR Spfy C&C Order";

    trigger OnRun()
    var
        CCOrder: Record "NPR Spfy C&C Order";
    begin
        CCOrder := Rec;
        if CCOrder.Find() and (CCOrder.Status <> CCOrder.Status::" ") then
            ImportOne(CCOrder);
        Rec := CCOrder;
    end;

    procedure ImportBatch(var CCOrderIn: Record "NPR Spfy C&C Order"; WithDialog: Boolean)
    var
        CCOrder: Record "NPR Spfy C&C Order";
        CCOrder2: Record "NPR Spfy C&C Order";
        Window: Dialog;
        RecNo: Integer;
        TotalRecNo: Integer;
        SuccessNo: Integer;
        WindowTxt001: Label 'Processing Shopify C&C Orders...\\';
        WindowTxt002: Label 'Order #1##### of #2#####\';
        DoneLbl: Label 'Done. Successfully proccessed %1 out of %2 orders.';
    begin
        if WithDialog then begin
            Window.Open(
                WindowTxt001 +
                WindowTxt002
            );
            RecNo := 0;
            TotalRecNo := CCOrderIn.Count();
            Window.Update(2, TotalRecNo);
        end;

        CCOrder.Copy(CCOrderIn);
        if CCOrder.FindSet() then
            repeat
                if WithDialog then begin
                    RecNo += 1;
                    Window.Update(1, RecNo);
                end;

                CCOrder2 := CCOrder;
                if ImportOne(CCOrder) then
                    SuccessNo += 1;
            until CCOrder.Next() = 0;

        if WithDialog then begin
            Window.Close();
            Message(DoneLbl, SuccessNo, TotalRecNo);
        end;
    end;

    procedure ImportOne(var CCOrder: Record "NPR Spfy C&C Order") Success: Boolean
    var
        SpfyCCOrderHandler: Codeunit "NPR Spfy C&C Order Handler";
    begin
        ClearLastError();
        Commit();
        Success := Codeunit.Run(Codeunit::"NPR Spfy C&C Order Handler", CCOrder);
        if not Success then
            if CCOrder.Find() then begin
                CCOrder.SetErrorMessage(GetLastErrorText());
                CCOrder.Status := CCOrder.Status::Error;
                SpfyCCOrderHandler.ModifyCCOrderWithoutDatalog(CCOrder);
                Commit();
            end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Spfy C&C Order", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnNewCCOrderWebhookRequest(var Rec: Record "NPR Spfy C&C Order")
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        if Rec.IsTemporary() or (Rec.Status <> Rec.Status::New) then
            exit;
        if not SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Click And Collect") then
            exit;

        Codeunit.Run(Codeunit::"NPR Spfy C&C Order - Import", Rec);
    end;
}
#endif