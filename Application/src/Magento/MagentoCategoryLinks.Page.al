page 6151418 "NPR Magento Category Links"
{
    Extensible = False;
    Caption = 'Magento Category Links';
    DelayedInsert = true;
    LinksAllowed = false;
    PageType = ListPart;
    UsageCategory = Administration;

    ShowFilter = false;
    SourceTable = "NPR Magento Category Link";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Category Id"; Rec."Category Id")
                {

                    ToolTip = 'Specifies the value of the Category Id field';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Specifies the value of the Category Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Position; Rec.Position)
                {

                    ToolTip = 'Specifies the value of the Position field';
                    ApplicationArea = NPRRetail;
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
