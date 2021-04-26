page 6151529 "NPR Nc Collector Card"
{
    Caption = 'Nc Collector Card';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Nc Collector";

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
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table No. field';
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Name field';
                }
                field(Active; Rec.Active)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Active field';
                }
                field("Max. Lines per Collection"; Rec."Max. Lines per Collection")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Max. Lines per Collection field';
                }
                field("Wait to Send"; Rec."Wait to Send")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Wait to Send field';
                }
                field("Delete Obsolete Lines"; Rec."Delete Obsolete Lines")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delete Obsolete Lines field';
                }
                field("Delete Sent Collections After"; Rec."Delete Sent Collections After")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delete Sent Collections After field';
                }
            }
            group(Changes)
            {
                field("Record Modify"; Rec."Record Modify")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Modify field';
                }
                field("Record Insert"; Rec."Record Insert")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Insert field';
                }
                field("Record Delete"; Rec."Record Delete")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delete field';
                }
                field("Record Rename"; Rec."Record Rename")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rename field';
                }
            }
            part(Control6150625; "NPR Nc Collec. Filters")
            {
                SubPageLink = "Collector Code" = FIELD(Code);
                ApplicationArea = All;
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
                ApplicationArea = All;
                ToolTip = 'Executes the Collection Lines action';
            }
            action(Collections)
            {
                Caption = 'Collections';
                Image = XMLFileGroup;
                RunObject = Page "NPR Nc Collection List";
                RunPageLink = "Collector Code" = FIELD(Code);
                ApplicationArea = All;
                ToolTip = 'Executes the Collections action';
            }
        }
        area(processing)
        {
            action("Send all records as modify")
            {
                Caption = 'Send all records as modify';
                Image = BulletList;
                ApplicationArea = All;
                ToolTip = 'Executes the Send all records as modify action';

                trigger OnAction()
                begin
                    NcCollectorManagement.CreateModifyCollectionLines(Rec);
                end;
            }
        }
    }

    var
        NcCollectorManagement: Codeunit "NPR Nc Collector Management";
}

