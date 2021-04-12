page 6014604 "NPR Attribute Card"
{
    // NPR4.11/TSA/20150422  CASE 209946 - Entity and Shortcut Attributes
    // NPR5.35/ANEN/20170608 CASE 276486 Support for lookup from table
    // NPR5.39/BR  /20180215 CASE 295322 Added field Import File Column No.
    // NPR5.41/TS  /20180105 CASE 300893 Removed Caption on ActionContainer

    Caption = 'Client Attribute Card';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Attribute";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Code Caption"; Rec."Code Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code Caption field';
                }
                field("Filter Caption"; Rec."Filter Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Filter Caption field';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
                field(Global; Rec.Global)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global field';
                }
                field("Value Datatype"; Rec."Value Datatype")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Value Datatype field';
                }
                field("On Validate"; Rec."On Validate")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the On Validate field';
                }
                field("On Format"; Rec."On Format")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the On Format field';
                }
                field("LookUp Table"; Rec."LookUp Table")
                {
                    ApplicationArea = All;
                    ToolTip = 'LookUp Table overide manual set lookup value.';
                }
                field("LookUp Table Id"; Rec."LookUp Table Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the LookUp Table Id field';
                }
                field("LookUp Table Name"; Rec."LookUp Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the LookUp Table Name field';
                }
                field("LookUp Value Field Id"; Rec."LookUp Value Field Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the LookUp Value Field Id field';
                }
                field("LookUp Value Field Name"; Rec."LookUp Value Field Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the LookUp Value Field Name field';
                }
                field("LookUp Description Field Id"; Rec."LookUp Description Field Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the LookUp Description Field Id field';
                }
                field("LookUp Description Field Name"; Rec."LookUp Description Field Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the LookUp Description Field Name field';
                }
                field("Import File Column No."; Rec."Import File Column No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Import File Column No. field';
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
}

