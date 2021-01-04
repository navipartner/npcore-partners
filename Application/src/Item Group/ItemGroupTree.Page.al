page 6014427 "NPR Item Group Tree"
{
    // NPR5.20/JDH/20160309 CASE 234014 added sorting key (not visible by default) + changed key to Sorting key
    // NPR5.23/BRI /20160523 CASE 242360 Removed the field "Used" to fix performance issues
    // NPR5.29/TJ  /20170123 CASE 263787 Commented out code under action Dimensions-Multiple and set Visible property to FALSE
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action
    // NPR5.48/BHR /20190115 CASE 334217 Add field Type

    Caption = 'Item Group Tree';
    CardPageID = "NPR Item Group Page";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Item Group";
    SourceTableView = SORTING("Sorting-Key");
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                IndentationColumn = Level;
                IndentationControls = "No.", Description;
                ShowAsTree = true;
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field(Picture; Picture)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Picture field';
                }
                field("Parent Item Group No."; "Parent Item Group No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Parent Item Group No. field';
                }
                field("No. Series"; "No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. Series field';
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                }
                field("Global Dimension 2 Code"; "Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                }
                field("Inventory Posting Group"; "Inventory Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Inventory Posting Group field';
                }
                field("Gen. Bus. Posting Group"; "Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gen. Bus. Posting Group field';
                }
                field("Gen. Prod. Posting Group"; "Gen. Prod. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gen. Prod. Posting Group field';
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
                field(Level; Level)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Level field';
                }
                field("Sorting-Key"; "Sorting-Key")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Sorting Key field';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Dimension)
            {
                Caption = 'Dimensions';
                Image = Dimensions;
                action("Dimensions-Single")
                {
                    Caption = 'Dimensions-Single';
                    Image = Dimensions;
                    RunObject = Page "Default Dimensions";
                    RunPageLink = "Table ID" = CONST(6014410),
                                  "No." = FIELD("No.");
                    ShortCutKey = 'Shift+Ctrl+D';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Dimensions-Single action';
                }
                action("Dimensions-Mulitple")
                {
                    Caption = 'Dimensions-Mulitple';
                    Image = DimensionSets;
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Dimensions-Mulitple action';

                    trigger OnAction()
                    var
                        ItemGroup: Record "NPR Item Group";
                        DefaultDimMultiple: Page "Default Dimensions-Multiple";
                    begin
                        //-NPR5.29 [263787]
                        /*
                        CurrPage.SETSELECTIONFILTER(ItemGroup);
                        DefaultDimMultiple.SetMultiItemGroup(ItemGroup);
                        DefaultDimMultiple.RUNMODAL;
                        */
                        //+NPR5.29 [263787]

                    end;
                }
            }
        }
        area(processing)
        {
            group("Item Group")
            {
                Caption = 'Item Group';
                action("Load Image")
                {
                    Caption = 'Load Image';
                    Image = Picture;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Load Image action';

                    trigger OnAction()
                    var
                        TempBlob: Codeunit "Temp Blob";
                        FileManagement: Codeunit "File Management";
                        PictureExists: Boolean;
                        Name: Text[100];
                        i: Integer;
                    begin
                        PictureExists := Picture.HasValue;
                        Name := FileManagement.BLOBImport(TempBlob, '*.BMP');

                        if Name = '' then
                            exit;

                        while (StrPos(Name, '.') > 0) do begin
                            i := StrPos(Name, '.');
                            Name := CopyStr(Name, i + 1);
                        end;

                        "Picture Extention" := Name;
                        Rec.Modify();
                    end;
                }
                action("Create Item From Item Group")
                {
                    Caption = 'Create Item(s) From Item Group';
                    Image = ItemGroup;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Create Item(s) From Item Group action';

                    trigger OnAction()
                    var
                        ItemGroupSelected: Record "NPR Item Group";
                        CreateItemReport: Report "NPR Create Item From ItemGr.";
                        ItemGroupSelectedMark: Record "NPR Item Group";
                        FilterText: Text;
                    begin
                        CurrPage.SetSelectionFilter(ItemGroupSelected);
                        REPORT.Run(6014610, true, false, ItemGroupSelected);
                    end;
                }
            }
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("Update Item Group Structure")
                {
                    Caption = 'Indent Item Groups';
                    Image = IndentChartOfAccounts;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Indent Item Groups action';

                    trigger OnAction()
                    var
                        CreateItemGroupStructure: Codeunit "NPR Create Item Group Struct.";
                    begin
                        CreateItemGroupStructure.Run;
                    end;
                }
            }
        }
    }
}

