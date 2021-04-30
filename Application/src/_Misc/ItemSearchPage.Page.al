page 6060045 "NPR Item Search Page"
{
    Caption = 'Item Search Page';
    UsageCategory = Documents;
    ApplicationArea = All;
    layout
    {
        area(content)
        {
            group(General)
            {
                field(ExternalItemNo; ExternalItemNo)
                {
                    ApplicationArea = All;
                    Caption = 'External Item No';
                    ToolTip = 'Specifies the value of the External Item No field';
                }
                field(ExternalType; ExternalType)
                {
                    ApplicationArea = All;
                    Caption = 'External Type';
                    OptionCaption = 'All,VendorItemNo,Barcode,CrossReference,AlternativeNo';
                    ToolTip = 'Specifies the value of the External Type field';
                }
                field(VendorNo; VendorNo)
                {
                    ApplicationArea = All;
                    Caption = 'Vendor No.';
                    TableRelation = Vendor."No.";
                    ToolTip = 'Specifies the value of the Vendor No. field';
                }
                field(UnitOfMeasure; UnitOfMeasure)
                {
                    ApplicationArea = All;
                    Caption = 'Unit Of Measure';
                    TableRelation = "Unit of Measure";
                    ToolTip = 'Specifies the value of the Unit Of Measure field';
                }
                field(ItemNo; ItemNo)
                {
                    ApplicationArea = All;
                    Caption = 'Item No.';
                    Editable = false;
                    TableRelation = Item."No.";
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field(VariantCode; VariantCode)
                {
                    ApplicationArea = All;
                    Caption = 'Variant Code';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field(FoundItem; FoundItem)
                {
                    ApplicationArea = All;
                    Caption = 'Found Item';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Found Item field';
                }
                field(SearchTime; Searchtime)
                {
                    ApplicationArea = All;
                    Caption = 'Search time (seconds)';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Search time (seconds) field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Search)
            {
                Caption = 'Search';
                Image = "Action";
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Search action';

                trigger OnAction()
                begin
                    FindItem();
                end;
            }
        }
    }

    var
        ItemNumberManagement: Codeunit "NPR Item Number Mgt.";
        FoundItem: Boolean;
        VariantCode: Code[10];
        UnitOfMeasure: Code[10];
        ItemNo: Code[20];
        VendorNo: Code[20];
        Searchtime: Decimal;
        ExternalType: Option All,VendorItemNo,Barcode,CrossReference,AlternativeNo;
        ExternalItemNo: Text[50];

    local procedure FindItem()
    var
        StartSearch: Time;
    begin
        StartSearch := Time;
        FoundItem := ItemNumberManagement.FindItemInfo(ExternalItemNo,
                               ExternalType,
                               false,
                               UnitOfMeasure,
                               VendorNo,
                               ItemNo,
                               VariantCode);
        if not FoundItem then begin
            ItemNo := '';
            VariantCode := '';
        end;
        Searchtime := Round((Time - StartSearch) / 1000, 0.01);
    end;
}

