page 6014480 "NPR Object List"
{
    Caption = 'Object List';
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'Types,Action,Reports_caption,Category4_caption,Category5_caption,Category6_caption,Category7_caption,Category8_caption,Category9_caption,Category10_caption';
    SourceTable = AllObj;
    SourceTableView = SORTING("Object Type", "Object ID")
                      ORDER(Ascending)
                      WHERE("Object Type" = FILTER(<> TableData));
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Control1160150004)
            {
                ShowCaption = false;
                field("Object Type"; Rec."Object Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Object Type field';
                }
                field("Object ID"; Rec."Object ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Object ID field';
                }
                field("Object Name"; Rec."Object Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Object Name field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Sortering)
            {
                Caption = 'Sorting';
                action("Table")
                {
                    Caption = 'Table';
                    Image = "Table";
                    Promoted = true;
                    PromotedOnly = true;
                    ShortCutKey = 'Ctrl+Alt+b';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Table action';

                    trigger OnAction()
                    begin
                        Rec.SetRange("Object Type", ObjectTypeOpt::Table);
                    end;
                }
                action("CodeUnit")
                {
                    Caption = 'CodeUnit';
                    Image = ExplodeBOM;
                    Promoted = true;
                    PromotedOnly = true;
                    ShortCutKey = 'Ctrl+Alt+c';
                    ApplicationArea = All;
                    ToolTip = 'Executes the CodeUnit action';

                    trigger OnAction()
                    begin
                        Rec.SetRange("Object Type", ObjectTypeOpt::Codeunit);
                    end;
                }
                action("Report")
                {
                    Caption = 'Report';
                    Image = "Report";
                    Promoted = true;
                    PromotedOnly = true;
                    ShortCutKey = 'Ctrl+Alt+p';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Report action';

                    trigger OnAction()
                    begin
                        Rec.SetRange("Object Type", ObjectTypeOpt::Report);
                    end;
                }
                action("Page")
                {
                    Caption = 'Page';
                    Image = VendorLedger;
                    Promoted = true;
                    PromotedOnly = true;
                    ShortCutKey = 'Ctrl+Alt+g';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Page action';

                    trigger OnAction()
                    begin
                        Rec.SetRange("Object Type", ObjectTypeOpt::Page);
                    end;
                }
                action("XMLPort")
                {
                    Caption = 'XMLPort';
                    Image = Export;
                    Promoted = true;
                    PromotedOnly = true;
                    ShortCutKey = 'Ctrl+Alt+x';
                    ApplicationArea = All;
                    ToolTip = 'Executes the XMLPort action';

                    trigger OnAction()
                    begin
                        Rec.SetRange("Object Type", ObjectTypeOpt::XMLPort);
                    end;
                }
                action(All)
                {
                    Caption = 'All';
                    Image = AllLines;
                    Promoted = true;
                    PromotedOnly = true;
                    ShortCutKey = 'Ctrl+Alt+a';
                    ApplicationArea = All;
                    ToolTip = 'Executes the All action';

                    trigger OnAction()
                    begin
                        Rec.Reset();
                    end;
                }
            }
            action("RUN")
            {
                Caption = 'Run';
                Image = Start;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Ctrl+r';
                ApplicationArea = All;
                ToolTip = 'Executes the Run action';

                trigger OnAction()
                begin
                    case Rec."Object Type" of
                        Rec."Object Type"::Table:
                            HyperLink(GetUrl(CLIENTTYPE::Current, CompanyName, OBJECTTYPE::Table, Rec."Object ID"));
                        Rec."Object Type"::Page:
                            PAGE.Run(Rec."Object ID");
                        Rec."Object Type"::Report:
                            REPORT.Run(Rec."Object ID");
                        Rec."Object Type"::Codeunit:
                            CODEUNIT.Run(Rec."Object ID");
                        Rec."Object Type"::XMLport:
                            XMLPORT.Run(Rec."Object ID");
                    end;
                end;
            }
        }
    }

    var
        ObjectTypeOpt: Option All,"Table",Form,"Report",Dataport,"Codeunit","XMLPort","Menu Suite","Page";
}

