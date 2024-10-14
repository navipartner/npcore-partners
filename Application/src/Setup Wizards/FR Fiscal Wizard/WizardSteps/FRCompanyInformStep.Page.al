page 6184822 "NPR FR Company Inform. Step"
{
    Caption = 'FR Company Information Setup';
    Extensible = false;
    PageType = ListPart;
    SourceTable = "Company Information";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(CompanyInfo)
            {
                field("VAT Registration No."; Rec."VAT Registration No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the VAT Registration Number of the company.';
                }
                field("APE Code"; APECode)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'APE Code';
                    ToolTip = 'Specifies the APE code for the company.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;

    internal procedure IsDataPopulated(): Boolean
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        RecRef.GetTable(Rec);

        if RecRef.FieldExist(10802) then begin
            FieldRef := RecRef.Field(10802);

            APECode := FieldRef.Value;
            exit((APECode <> '') and (Rec."VAT Registration No." <> ''));
        end;

        exit(false);
    end;

    internal procedure CopyRealToTemp()
    begin
        if not Rec.Get() then
            exit;
        Rec.TransferFields(Rec);
        if not Rec.Insert() then
            Rec.Modify();
    end;

    internal procedure CreateCompanyInfoData()
    var
        CompanyInfoTemp: Record "Company Information";
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        if not Rec.Get() then
            exit;

        CompanyInfoTemp.Get();
        RecRef.GetTable(CompanyInfoTemp);
        CompanyInfoTemp."VAT Registration No." := Rec."VAT Registration No.";
        if RecRef.FieldExist(10802) then begin
            FieldRef := RecRef.Field(10802);
            FieldRef.Value := APECode;
        end;
        if not CompanyInfoTemp.Insert() then
            CompanyInfoTemp.Modify();
    end;

    var
        APECode: Text[6];
}