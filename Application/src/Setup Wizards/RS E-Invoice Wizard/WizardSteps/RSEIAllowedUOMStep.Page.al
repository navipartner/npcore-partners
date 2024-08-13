page 6184733 "NPR RS EI Allowed UOM Step"
{
    Caption = 'Allowed Units of Measure Setup';
    DeleteAllowed = false;
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = "NPR RS EI Allowed UOM";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRRSEInvoice;
                    ToolTip = 'Specifies the value of the Code field.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = NPRRSEInvoice;
                    ToolTip = 'Specifies the value of the Name field.';
                }
                field("Configuration Date"; Rec."Configuration Date")
                {
                    ApplicationArea = NPRRSEInvoice;
                    ToolTip = 'Specifies the value of the Configuration Date field.';
                }
            }
        }
    }

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    actions
    {
        area(Processing)
        {
            action(GetAllowedUOMs)
            {
                ApplicationArea = NPRRSEInvoice;
                Caption = 'Get Allowed Unit of Measuers';
                Image = Administration;
                ToolTip = 'Executing this Action, the allowed Units of Measure will be pulled from the E-Invoice API.';
                trigger OnAction()
                var
                    RSEICommunicationMgt: Codeunit "NPR RS EI Communication Mgt.";
                begin
                    RSEICommunicationMgt.GetAllowedUOMs();
                end;
            }
        }
    }
#endif

    internal procedure CopyRealToTemp()
    begin
        if RSEIAllowedUOM.IsEmpty() then
            exit;
        RSEIAllowedUOM.FindSet();
        repeat
            Rec.TransferFields(RSEIAllowedUOM);
            if not Rec.Insert() then
                Rec.Modify();
        until RSEIAllowedUOM.Next() = 0;
    end;

    internal procedure RSEIAllowedUOMDataToCreate(): Boolean
    begin
        exit(Rec.FindFirst());
    end;

    internal procedure CreateRSEIAllowedUOMData()
    begin
        if Rec.IsEmpty() then
            exit;
        Rec.FindSet();
        repeat
            RSEIAllowedUOM.TransferFields(Rec);
            if not RSEIAllowedUOM.Insert() then
                RSEIAllowedUOM.Modify();
        until Rec.Next() = 0;
    end;

    var
        RSEIAllowedUOM: Record "NPR RS EI Allowed UOM";
}