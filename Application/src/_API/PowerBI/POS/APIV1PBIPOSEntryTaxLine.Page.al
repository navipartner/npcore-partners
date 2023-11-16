page 6060003 "NPR APIV1 PBIPOSEntryTaxLine"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'posEntryTaxLine';
    EntitySetName = 'posEntryTaxLines';
    Caption = 'PowerBI POS Entry Tax Line';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR POS Entry Tax Line";
    Extensible = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'SystemId', Locked = true;
                }
                field(posEntryNo; Rec."POS Entry No.")
                {
                    Caption = 'POS Entry No.', Locked = true;
                }
                field(tax; Rec."Tax %")
                {
                    Caption = 'Tax %', Locked = true;
                }
                field(vatIdentifier; Rec."VAT Identifier")
                {
                    Caption = 'VAT Identifier', Locked = true;
                }
                field(taxAmount; Rec."Tax Amount")
                {
                    Caption = 'Tax Amount', Locked = true;
                }
                field(taxBaseAmount; Rec."Tax Base Amount")
                {
                    Caption = 'Tax Base Amount', Locked = true;
                }
                field(amountIncludingTax; Rec."Amount Including Tax")
                {
                    Caption = 'Amount Including Tax', Locked = true;
                }
                field(lastModifiedDateTime; PowerBIUtils.GetSystemModifedAt(Rec.SystemModifiedAt))
                {
                    Caption = 'Last Modified Date', Locked = true;
                }
                field(lastModifiedDateTimeFilter; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date Filter', Locked = true;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        CurrRecordRef: RecordRef;
    begin
        CurrRecordRef.GetTable(Rec);
        PowerBIUtils.UpdateSystemModifiedAtfilter(CurrRecordRef);
    end;

    var
        PowerBIUtils: Codeunit "NPR PowerBI Utils";
}