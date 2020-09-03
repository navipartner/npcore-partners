page 6014480 "NPR Object List"
{
    // NPR70.00.01.01/MH/20150119  Added "Object Type"::Table to RUN Action.
    // NPR5.26/MMV /20160825 CASE 241549 Changed page type from card to list to get search bar in web client.
    // NPR5.27/TR  /20161019  CASE 255778 Added ShortCutKeys for all actions.
    // NPR5.41/TS  /20180105  CASE 300893 Removed Caption on Action Container
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action

    Caption = 'Object List';
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'Types,Action,Reports_caption,Category4_caption,Category5_caption,Category6_caption,Category7_caption,Category8_caption,Category9_caption,Category10_caption';
    SourceTable = AllObj;
    SourceTableView = SORTING("Object Type", "Object ID")
                      ORDER(Ascending)
                      WHERE("Object Type" = FILTER(<> TableData));
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1160150004)
            {
                ShowCaption = false;
                field("Object Type"; "Object Type")
                {
                    ApplicationArea = All;
                }
                field("Object ID"; "Object ID")
                {
                    ApplicationArea = All;
                }
                field("Object Name"; "Object Name")
                {
                    ApplicationArea = All;
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
                    ShortCutKey = 'Ctrl+Alt+b';

                    trigger OnAction()
                    begin
                        SetRange("Object Type", ObjectTypeOpt::Table);
                    end;
                }
                action("CodeUnit")
                {
                    Caption = 'CodeUnit';
                    Image = ExplodeBOM;
                    Promoted = true;
                    ShortCutKey = 'Ctrl+Alt+c';

                    trigger OnAction()
                    begin
                        SetRange("Object Type", ObjectTypeOpt::Codeunit);
                    end;
                }
                action("Report")
                {
                    Caption = 'Report';
                    Image = "Report";
                    Promoted = true;
                    ShortCutKey = 'Ctrl+Alt+p';

                    trigger OnAction()
                    begin
                        SetRange("Object Type", ObjectTypeOpt::Report);
                    end;
                }
                action("Page")
                {
                    Caption = 'Page';
                    Image = VendorLedger;
                    Promoted = true;
                    ShortCutKey = 'Ctrl+Alt+g';

                    trigger OnAction()
                    begin
                        SetRange("Object Type", ObjectTypeOpt::Page);
                    end;
                }
                action("XMLPort")
                {
                    Caption = 'XMLPort';
                    Image = Export;
                    Promoted = true;
                    ShortCutKey = 'Ctrl+Alt+x';

                    trigger OnAction()
                    begin
                        SetRange("Object Type", ObjectTypeOpt::XMLPort);
                    end;
                }
                action(All)
                {
                    Caption = 'All';
                    Image = AllLines;
                    Promoted = true;
                    ShortCutKey = 'Ctrl+Alt+a';

                    trigger OnAction()
                    begin
                        Reset;
                    end;
                }
            }
            action("RUN")
            {
                Caption = 'Run';
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Ctrl+r';

                trigger OnAction()
                begin
                    //-NPR70.00.00.01
                    //IF "Object Type"="Object Type"::Codeunit THEN
                    //  CODEUNIT.RUN("Object ID");
                    //IF "Object Type"="Object Type"::Report THEN
                    //  REPORT.RUN("Object ID");
                    //IF "Object Type"="Object Type"::Page THEN
                    //  PAGE.RUN("Object ID");
                    //IF "Object Type"="Object Type"::XMLport THEN
                    //  XMLPORT.RUN("Object ID");
                    case "Object Type" of
                        "Object Type"::Table:
                            HyperLink(GetUrl(CLIENTTYPE::Current, CompanyName, OBJECTTYPE::Table, "Object ID"));
                        "Object Type"::Page:
                            PAGE.Run("Object ID");
                        "Object Type"::Report:
                            REPORT.Run("Object ID");
                        "Object Type"::Codeunit:
                            CODEUNIT.Run("Object ID");
                        "Object Type"::XMLport:
                            XMLPORT.Run("Object ID");
                    end;
                    //+NPR70.00.01.01
                end;
            }
        }
    }

    var
        ObjectTypeOpt: Option All,"Table",Form,"Report",Dataport,"Codeunit","XMLPort","Menu Suite","Page";
}

