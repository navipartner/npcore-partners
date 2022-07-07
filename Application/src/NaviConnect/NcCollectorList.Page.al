page 6151528 "NPR Nc Collector List"
{
    Extensible = False;
    Caption = 'Nc Collector List';
    CardPageID = "NPR Nc Collector Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Nc Collector";
    UsageCategory = Administration;
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
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRNaviConnect;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Table No."; Rec."Table No.")
                {

                    ToolTip = 'Specifies the value of the Table No. field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Table Name"; Rec."Table Name")
                {

                    ToolTip = 'Specifies the value of the Table Name field';
                    ApplicationArea = NPRNaviConnect;
                }
                field(Active; Rec.Active)
                {

                    ToolTip = 'Specifies the value of the Active field';
                    ApplicationArea = NPRNaviConnect;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Collection Lines")
            {
                Caption = 'Collection Lines';
                Image = XMLFile;
                RunObject = Page "NPR Nc Collection Lines";
                RunPageLink = "Collector Code" = FIELD(Code);

                ToolTip = 'Executes the Collection Lines action';
                ApplicationArea = NPRNaviConnect;
            }
            action(Collections)
            {
                Caption = 'Collections';
                Image = XMLFileGroup;
                RunObject = Page "NPR Nc Collection List";
                RunPageLink = "Collector Code" = FIELD(Code);

                ToolTip = 'Executes the Collections action';
                ApplicationArea = NPRNaviConnect;
            }
        }
    }
}

