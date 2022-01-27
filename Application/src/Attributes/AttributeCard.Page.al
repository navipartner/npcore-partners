page 6014604 "NPR Attribute Card"
{
    Extensible = False;
    // NPR4.11/TSA/20150422  CASE 209946 - Entity and Shortcut Attributes
    // NPR5.35/ANEN/20170608 CASE 276486 Support for lookup from table
    // NPR5.39/BR  /20180215 CASE 295322 Added field Import File Column No.
    // NPR5.41/TS  /20180105 CASE 300893 Removed Caption on ActionContainer

    Caption = 'Client Attribute Card';
    PageType = Card;
    UsageCategory = Administration;

    SourceTable = "NPR Attribute";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Code Caption"; Rec."Code Caption")
                {

                    ToolTip = 'Specifies the value of the Code Caption field';
                    ApplicationArea = NPRRetail;
                }
                field("Filter Caption"; Rec."Filter Caption")
                {

                    ToolTip = 'Specifies the value of the Filter Caption field';
                    ApplicationArea = NPRRetail;
                }
                field(Blocked; Rec.Blocked)
                {

                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NPRRetail;
                }
                field(Global; Rec.Global)
                {

                    ToolTip = 'Specifies the value of the Global field';
                    ApplicationArea = NPRRetail;
                }
                field("Value Datatype"; Rec."Value Datatype")
                {

                    ToolTip = 'Specifies the value of the Value Datatype field';
                    ApplicationArea = NPRRetail;
                }
                field("On Validate"; Rec."On Validate")
                {

                    ToolTip = 'Specifies the value of the On Validate field';
                    ApplicationArea = NPRRetail;
                }
                field("On Format"; Rec."On Format")
                {

                    ToolTip = 'Specifies the value of the On Format field';
                    ApplicationArea = NPRRetail;
                }
                field("LookUp Table"; Rec."LookUp Table")
                {

                    ToolTip = 'LookUp Table overide manual set lookup value.';
                    ApplicationArea = NPRRetail;
                }
                field("LookUp Table Id"; Rec."LookUp Table Id")
                {

                    ToolTip = 'Specifies the value of the LookUp Table Id field';
                    ApplicationArea = NPRRetail;
                }
                field("LookUp Table Name"; Rec."LookUp Table Name")
                {

                    ToolTip = 'Specifies the value of the LookUp Table Name field';
                    ApplicationArea = NPRRetail;
                }
                field("LookUp Value Field Id"; Rec."LookUp Value Field Id")
                {

                    ToolTip = 'Specifies the value of the LookUp Value Field Id field';
                    ApplicationArea = NPRRetail;
                }
                field("LookUp Value Field Name"; Rec."LookUp Value Field Name")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the LookUp Value Field Name field';
                    ApplicationArea = NPRRetail;
                }
                field("LookUp Description Field Id"; Rec."LookUp Description Field Id")
                {

                    ToolTip = 'Specifies the value of the LookUp Description Field Id field';
                    ApplicationArea = NPRRetail;
                }
                field("LookUp Description Field Name"; Rec."LookUp Description Field Name")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the LookUp Description Field Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Import File Column No."; Rec."Import File Column No.")
                {

                    ToolTip = 'Specifies the value of the Import File Column No. field';
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

                ToolTip = 'Executes the Attribute ID action';
                ApplicationArea = NPRRetail;
            }
            action(Translations)
            {
                Caption = 'Translations';
                Image = Translation;
                RunObject = Page "NPR Attribute Translations";
                RunPageLink = "Attribute Code" = FIELD(Code);
                RunPageView = SORTING("Attribute Code", "Language ID");

                ToolTip = 'Executes the Translations action';
                ApplicationArea = NPRRetail;
            }
            action(Values)
            {
                Caption = 'Values';
                Image = List;
                RunObject = Page "NPR Attribute Value Lookup";
                RunPageLink = "Attribute Code" = FIELD(Code);
                RunPageView = SORTING("Attribute Code");

                ToolTip = 'Executes the Values action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

