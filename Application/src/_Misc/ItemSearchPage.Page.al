page 6060045 "NPR Item Search Page"
{
    Caption = 'Item Search Page';
    UsageCategory = Documents;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(ExternalItemNo; ExternalItemNo)
                {

                    Caption = 'External Item No';
                    ToolTip = 'Specifies the value of the External Item No field';
                    ApplicationArea = NPRRetail;
                }
                field(ExternalType; ExternalType)
                {

                    Caption = 'External Type';
                    OptionCaption = 'All,VendorItemNo,Barcode,CrossReference,AlternativeNo';
                    ToolTip = 'Specifies the value of the External Type field';
                    ApplicationArea = NPRRetail;
                }
                field(VendorNo; VendorNo)
                {

                    Caption = 'Vendor No.';
                    TableRelation = Vendor."No.";
                    ToolTip = 'Specifies the value of the Vendor No. field';
                    ApplicationArea = NPRRetail;
                }
                field(UnitOfMeasure; UnitOfMeasure)
                {

                    Caption = 'Unit Of Measure';
                    TableRelation = "Unit of Measure";
                    ToolTip = 'Specifies the value of the Unit Of Measure field';
                    ApplicationArea = NPRRetail;
                }
                field(ItemNo; ItemNo)
                {

                    Caption = 'Item No.';
                    Editable = false;
                    TableRelation = Item."No.";
                    ToolTip = 'Specifies the value of the Item No. field';
                    ApplicationArea = NPRRetail;
                }
                field(VariantCode; VariantCode)
                {

                    Caption = 'Variant Code';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = NPRRetail;
                }
                field(FoundItem; FoundItem)
                {

                    Caption = 'Found Item';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Found Item field';
                    ApplicationArea = NPRRetail;
                }
                field(SearchTime; Searchtime)
                {

                    Caption = 'Search time (seconds)';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Search time (seconds) field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Search action';
                ApplicationArea = NPRRetail;

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

