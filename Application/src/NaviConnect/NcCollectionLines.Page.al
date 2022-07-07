﻿page 6151532 "NPR Nc Collection Lines"
{
    Extensible = False;
    Caption = 'Nc Collection Lines';
    Editable = false;
    PageType = List;
    SourceTable = "NPR Nc Collection Line";
    UsageCategory = Lists;
    ApplicationArea = NPRNaviConnect;
    ObsoleteState = Pending;
    ObsoleteReason = 'Task Queue module is about to be removed from NpCore so NC Collector is also going to be removed.';
    ObsoleteTag = 'BC 20 - Task Queue deprecating starting from 28/06/2022';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Collector Code"; Rec."Collector Code")
                {

                    ToolTip = 'Specifies the value of the Collector Code field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Collection No."; Rec."Collection No.")
                {

                    ToolTip = 'Specifies the value of the Collection No. field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Type of Change"; Rec."Type of Change")
                {

                    ToolTip = 'Specifies the value of the Type of Change field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Record ID"; Rec."Record ID")
                {

                    ToolTip = 'Specifies the value of the Record ID field';
                    ApplicationArea = NPRNaviConnect;
                }
                field(Obsolete; Rec.Obsolete)
                {

                    ToolTip = 'Specifies the value of the Obsolete field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Data log Record No."; Rec."Data log Record No.")
                {

                    ToolTip = 'Specifies the value of the Data log Record No. field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Table No."; Rec."Table No.")
                {

                    ToolTip = 'Specifies the value of the Table No. field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("PK Code 1"; Rec."PK Code 1")
                {

                    ToolTip = 'Specifies the value of the PK Code 1 field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("PK Code 2"; Rec."PK Code 2")
                {

                    ToolTip = 'Specifies the value of the PK Code 2 field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("PK Line 1"; Rec."PK Line 1")
                {

                    ToolTip = 'Specifies the value of the PK Line 1 field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("PK Option 1"; Rec."PK Option 1")
                {

                    ToolTip = 'Specifies the value of the PK Option 1 field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Date Created"; Rec."Date Created")
                {

                    ToolTip = 'Specifies the value of the Date Created field';
                    ApplicationArea = NPRNaviConnect;
                }
            }
        }
    }
}

