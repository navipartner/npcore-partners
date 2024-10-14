page 6184821 "NPR FR Audit VAT ID Setup Step"
{
    Caption = 'FR POS Audit Profile Setup';
    Extensible = false;
    PageType = ListPart;
    SourceTable = "NPR FR Audit Setup";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(VATID)
            {
                Caption = 'VAT ID Setup';
                field("Item VAT Identifier Filter"; VATIDFilter)
                {
                    ToolTip = 'Specifies the value of the Item VAT Identifier Filter field';
                    ApplicationArea = NPRRetail;
                    Caption = 'Item VAT Identifier Filter';
                    trigger OnValidate()
                    begin
                        Rec.SetVATIDFilter(VATIDFilter);
                        Rec.Modify();
                    end;

                    trigger OnAssistEdit()
                    var
                        FRAuditMgt: Codeunit "NPR FR Audit Mgt.";
                        NewFilter: Text;
                    begin
                        NewFilter := FRAuditMgt.GetItemVATIdentifierFilter(VATIDFilter);
                        if NewFilter <> '' then begin
                            VATIDFilter := NewFilter;
                            Rec.SetVATIDFilter(NewFilter);
                            Rec.Modify();
                        end;
                    end;
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

    internal procedure CopyRealToTemp()
    begin
        if not FRAuditSetup.Get() then
            exit;
        Rec.TransferFields(FRAuditSetup);
        if not Rec.Insert() then
            Rec.Modify();
    end;

    internal procedure CreateFRAuditVATIDData()
    begin
        if not Rec.Get() then
            exit;
        if not FRAuditSetup.Get() then
            FRAuditSetup.Init();
        Rec.CalcFields("Item VAT ID Filter");
        FRAuditSetup."Item VAT ID Filter" := Rec."Item VAT ID Filter";
        if not FRAuditSetup.Insert() then
            FRAuditSetup.Modify();
    end;

    internal procedure IsDataPopulated(): Boolean
    begin
        if not Rec.Get() then
            exit(false);
        exit(Rec."Item VAT ID Filter".HasValue());
    end;

    var
        FRAuditSetup: Record "NPR FR Audit Setup";
        VATIDFilter: Text;
}
