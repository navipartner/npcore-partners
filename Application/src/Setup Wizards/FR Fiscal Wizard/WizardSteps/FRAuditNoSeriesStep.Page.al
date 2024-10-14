page 6184815 "NPR FR Audit No Series Step"
{
    Caption = 'FR POS Audit Profile Setup';
    Extensible = false;
    PageType = ListPart;
    SourceTable = "NPR FR Audit No. Series";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Reprint No. Series"; Rec."Reprint No. Series")
                {
                    ToolTip = 'Specifies the value of the Reprint No. Series field';
                    ApplicationArea = NPRRetail;
                }
                field("JET No. Series"; Rec."JET No. Series")
                {
                    ToolTip = 'Specifies the value of the JET No. Series field';
                    ApplicationArea = NPRRetail;
                }
                field("Period No. Series"; Rec."Period No. Series")
                {
                    ToolTip = 'Specifies the value of the Period No. Series field';
                    ApplicationArea = NPRRetail;
                }
                field("Grand Period No. Series"; Rec."Grand Period No. Series")
                {
                    ToolTip = 'Specifies the value of the Grand Period No. Series field';
                    ApplicationArea = NPRRetail;
                }
                field("Yearly Period No. Series"; Rec."Yearly Period No. Series")
                {
                    ToolTip = 'Specifies the value of the Yearly Period No. Series field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    internal procedure CopyToTemp()
    var
        FRAuditNoSeries: Record "NPR FR Audit No. Series";
    begin
        if not FRAuditNoSeries.FindSet() then
            exit;

        repeat
            Rec.TransferFields(FRAuditNoSeries);
            if not Rec.Insert() then
                Rec.Modify();
        until FRAuditNoSeries.Next() = 0;
    end;

    internal procedure IsDataPopulated(): Boolean
    begin
        exit(CheckIsDataPopulated());
    end;

    internal procedure CreateAuditNOSeriesData()
    var
        FRAuditNoSeries: Record "NPR FR Audit No. Series";
    begin
        if Rec.FindSet() then
            repeat
                FRAuditNoSeries.TransferFields(Rec);
                if not FRAuditNoSeries.Insert() then
                    FRAuditNoSeries.Modify();
            until Rec.Next() = 0;
    end;

    local procedure CheckIsDataPopulated(): Boolean
    begin
        Rec.SetFilter("POS Unit No.", '<>%1', '');
        Rec.SetFilter("Reprint No. Series", '<>%1', '');
        Rec.SetFilter("JET No. Series", '<>%1', '');
        Rec.SetFilter("Period No. Series", '<>%1', '');
        Rec.SetFilter("Grand Period No. Series", '<>%1', '');
        Rec.SetFilter("Yearly Period No. Series", '<>%1', '');

        exit(Rec.FindFirst());
    end;
}