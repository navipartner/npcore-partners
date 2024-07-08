page 6014605 "NPR Attributes"
{
    Extensible = False;
    // NPR4.11/TSA /20150422 CASE 209946 - Entity and Shortcut Attributes
    // NPR5.30/BR  /20170213 CASE 252646 Added function GetViewText
    // NPR5.41/TS  /20180105 CASE 300893 Removed Caption on ActionContainer

    Caption = 'Client Attributes';
    ContextSensitiveHelpPage = 'docs/retail/attributes/how-to/client_attributes/client_attributes/';
    CardPageID = "NPR Attribute Card";
    PageType = List;
    SourceTable = "NPR Attribute";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies the code of the client attribute';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the name of the client attribute';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Attribute ID")
            {
                Caption = 'Attribute ID';
                Image = LinkWithExisting;
                RunObject = Page "NPR Attribute IDs";
                RunPageLink = "Attribute Code" = FIELD(Code);
                RunPageView = SORTING("Attribute Code")
                              ORDER(Ascending);

                ToolTip = 'Displays the attributes configured for the selected client attribute. You can add or edit attributes.';
                ApplicationArea = NPRRetail;
            }
            action(Translations)
            {
                Caption = 'Translations';
                Image = Translation;
                RunObject = Page "NPR Attribute Translations";
                RunPageLink = "Attribute Code" = FIELD(Code);
                RunPageView = SORTING("Attribute Code", "Language ID");

                ToolTip = 'Displays the translations configured for the selected client attribute. You can add or edit translations.';
                ApplicationArea = NPRRetail;
            }
            action(Values)
            {
                Caption = 'Values';
                Image = List;
                RunObject = Page "NPR Attribute Value Lookup";
                RunPageLink = "Attribute Code" = FIELD(Code);
                RunPageView = SORTING("Attribute Code");

                ToolTip = 'Displays the values configured for the selected client attribute. You can add or edit values.';
                ApplicationArea = NPRRetail;
            }
        }
    }

    internal procedure GetViewText(): Text
    begin
        //-NPR5.30 [252646]
        exit(Rec.GetView(false));
        //+NPR5.30 [252646]
    end;
}

