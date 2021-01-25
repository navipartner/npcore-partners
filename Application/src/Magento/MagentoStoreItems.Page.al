page 6151445 "NPR Magento Store Items"
{
    Caption = 'Magento Webshop Items';
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    ShowFilter = false;
    SourceTable = "NPR Magento Store Item";
    CardPageId = "NPR Magento Store Items Card";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Webshop; Webshop)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Webshop field';
                }
                field("Store Code"; "Store Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Store Code field';
                }
                field("Website Code"; "Website Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Website Code field';
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enabled field';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field(GetEnabledFieldsCaption; GetEnabledFieldsCaption)
                {
                    ApplicationArea = All;
                    Caption = 'Fields Enabled';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Fields Enabled field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        Storecode := "Store Code";
    end;

    var
        Storecode: Code[32];
}

