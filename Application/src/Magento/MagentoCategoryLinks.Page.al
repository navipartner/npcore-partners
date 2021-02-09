page 6151418 "NPR Magento Category Links"
{
    Caption = 'Magento Category Links';
    DelayedInsert = true;
    LinksAllowed = false;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    ShowFilter = false;
    SourceTable = "NPR Magento Category Link";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Category Id"; Rec."Category Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Category Id field';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        MagentoCategory: Record "NPR Magento Category";
                    begin
                        MagentoCategory.FilterGroup(2);
                        MagentoCategory.SetFilter("Root No.", RootNo);
                        MagentoCategory.FilterGroup(0);
                        if MagentoCategory.Get(Rec."Category Id") then;
                        if PAGE.RunModal(PAGE::"NPR Magento Category List", MagentoCategory) <> ACTION::LookupOK then
                            exit;

                        Rec.Validate("Category Id", MagentoCategory.Id);
                    end;
                }
                field("Category Name"; Rec."Category Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Category Name field';
                }
                field(Position; Rec.Position)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Position field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Root No." := RootNo;
    end;

    var
        RootNo: Code[20];

    procedure SetRootNo(NewRootNo: Code[20])
    begin
        RootNo := NewRootNo;
        Rec.FilterGroup(2);
        Rec.SetFilter("Root No.", RootNo);
        Rec.FilterGroup(0);
        CurrPage.Update(false);
    end;
}