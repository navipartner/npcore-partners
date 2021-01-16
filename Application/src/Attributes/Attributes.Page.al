page 6014605 "NPR Attributes"
{
    // NPR4.11/TSA /20150422 CASE 209946 - Entity and Shortcut Attributes
    // NPR5.30/BR  /20170213 CASE 252646 Added function GetViewText
    // NPR5.41/TS  /20180105 CASE 300893 Removed Caption on ActionContainer

    Caption = 'Client Attributes';
    CardPageID = "NPR Attribute Card";
    PageType = List;
    SourceTable = "NPR Attribute";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Attribute ID action';
            }
            action(Translations)
            {
                Caption = 'Translations';
                Image = Translation;
                RunObject = Page "NPR Attribute Translations";
                RunPageLink = "Attribute Code" = FIELD(Code);
                RunPageView = SORTING("Attribute Code", "Language ID");
                ApplicationArea = All;
                ToolTip = 'Executes the Translations action';
            }
            action(Values)
            {
                Caption = 'Values';
                Image = List;
                RunObject = Page "NPR Attribute Value Lookup";
                RunPageLink = "Attribute Code" = FIELD(Code);
                RunPageView = SORTING("Attribute Code");
                ApplicationArea = All;
                ToolTip = 'Executes the Values action';
            }
        }
    }

    procedure GetViewText(): Text
    begin
        //-NPR5.30 [252646]
        exit(Rec.GetView(false));
        //+NPR5.30 [252646]
    end;
}

