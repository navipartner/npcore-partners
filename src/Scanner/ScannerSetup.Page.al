page 6014535 "NPR Scanner - Setup"
{
    // NPR4.14/TS/20150820 CASE221150 Changed caption
    // NPR5.27/TJ/20160826 CASE 248276 Removed unused fields
    // NPR5.29/CLVA/20161122 CASE 252352 Added Group: FTP
    // NPR5.38/NPKNAV/20180126  CASE 299271 Transport NPR5.38 - 26 January 2018

    Caption = 'Scanner Card';
    SourceTable = "NPR Scanner - Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                grid(Control6150615)
                {
                    ShowCaption = false;
                    group(Control6150616)
                    {
                        ShowCaption = false;
                        field(ID; ID)
                        {
                            ApplicationArea = All;
                        }
                        field(Description; Description)
                        {
                            ApplicationArea = All;
                            Importance = Promoted;
                        }
                    }
                    group(Control6150619)
                    {
                        ShowCaption = false;
                        field(Type; Type)
                        {
                            ApplicationArea = All;
                        }
                        field(Port; Port)
                        {
                            ApplicationArea = All;
                        }
                        field("Clear Scanner Option"; "Clear Scanner Option")
                        {
                            ApplicationArea = All;
                        }
                        field(Debug; Debug)
                        {
                            ApplicationArea = All;
                        }
                    }
                }
            }
            group(Files)
            {
                Caption = 'Files';
                grid(Control6150626)
                {
                    ShowCaption = false;
                    group(Control6150627)
                    {
                        ShowCaption = false;
                        field("Path - EXE / DLL Directory"; "Path - EXE / DLL Directory")
                        {
                            ApplicationArea = All;
                        }
                        field("EXE - In"; "EXE - In")
                        {
                            ApplicationArea = All;
                        }
                        field("EXE - Out"; "EXE - Out")
                        {
                            ApplicationArea = All;
                        }
                        field("EXE - Update Scanner"; "EXE - Update Scanner")
                        {
                            ApplicationArea = All;
                        }
                        field("Path - Drop Directory"; "Path - Drop Directory")
                        {
                            ApplicationArea = All;
                        }
                        field("Path - Pickup Directory"; "Path - Pickup Directory")
                        {
                            ApplicationArea = All;
                        }
                        field("File - Name Type"; "File - Name Type")
                        {
                            ApplicationArea = All;
                        }
                        field("File - Name/Prefix"; "File - Name/Prefix")
                        {
                            ApplicationArea = All;
                        }
                        field("Import to Server Folder First"; "Import to Server Folder First")
                        {
                            ApplicationArea = All;
                        }
                        field("Local Client Scanner Folder"; "Local Client Scanner Folder")
                        {
                            ApplicationArea = All;
                        }
                        field("File - After"; "File - After")
                        {
                            ApplicationArea = All;
                        }
                        field("File - Backup Directory"; "File - Backup Directory")
                        {
                            ApplicationArea = All;
                        }
                        field("Backup Filename"; "Backup Filename")
                        {
                            ApplicationArea = All;
                            ToolTip = '%1 = CurrentDatetime';
                        }
                    }
                }
            }
            group("Format")
            {
                Caption = 'Format';
                grid(Control6150642)
                {
                    ShowCaption = false;
                    group("Number Format")
                    {
                        Caption = 'Number Format';
                        field("Decimal Point"; "Decimal Point")
                        {
                            ApplicationArea = All;
                        }
                        field("Leading Decimals"; "Leading Decimals")
                        {
                            ApplicationArea = All;
                        }
                        group("Before Communication")
                        {
                            Caption = 'Before Communication';
                            field("File - Line Skip Pre"; "File - Line Skip Pre")
                            {
                                ApplicationArea = All;
                            }
                            field("Placement Popup"; "Placement Popup")
                            {
                                ApplicationArea = All;
                            }
                            field("Alt. Import Codeunit"; "Alt. Import Codeunit")
                            {
                                ApplicationArea = All;
                                Caption = 'Alt. Import Codeunit';
                            }
                        }
                    }
                    group("Field Format")
                    {
                        Caption = 'Field Format';
                        field("Field Type"; "Field Type")
                        {
                            ApplicationArea = All;
                        }
                        field("Line Type"; "Line Type")
                        {
                            ApplicationArea = All;
                        }
                        field("Record Field Sep."; "Record Field Sep.")
                        {
                            ApplicationArea = All;
                        }
                        field("Prefix Length"; "Prefix Length")
                        {
                            ApplicationArea = All;
                        }
                        field("Scanning End String"; "Scanning End String")
                        {
                            ApplicationArea = All;
                        }
                        group("Weight Integration")
                        {
                            Caption = 'Weight Integration';
                            field("Weight - No. of MA Samples"; "Weight - No. of MA Samples")
                            {
                                ApplicationArea = All;
                            }
                        }
                    }
                }
            }
            group(FTP)
            {
                grid(Control6014401)
                {
                    ShowCaption = false;
                    group(Control6014402)
                    {
                        ShowCaption = false;
                        field("FTP Download to Server Folder"; "FTP Download to Server Folder")
                        {
                            ApplicationArea = All;
                        }
                        field("FTP Site address"; "FTP Site address")
                        {
                            ApplicationArea = All;
                        }
                        field("FTP Filename"; "FTP Filename")
                        {
                            ApplicationArea = All;
                        }
                        field("FTP Username"; "FTP Username")
                        {
                            ApplicationArea = All;
                        }
                        field("FTP Password"; "FTP Password")
                        {
                            ApplicationArea = All;
                        }
                    }
                }
            }
            group("Input Format")
            {
                Caption = 'Input Format';
                part(Control6150662; "NPR Scanner: Field Setup")
                {
                    SubPageLink = ID = FIELD(ID),
                                  "Where To" = CONST(Input);
                    SubPageView = SORTING(Order);
                    ApplicationArea=All;
                }
            }
            group("Output Format")
            {
                Caption = 'Output Format';
                part(Control6150664; "NPR Scanner: Field Setup")
                {
                    SubPageLink = ID = FIELD(ID),
                                  "Where To" = CONST(Output);
                    SubPageView = SORTING(Order);
                    ApplicationArea=All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Functions)
            {
                Caption = 'Functions';
                action(List)
                {
                    Caption = 'List';
                    Image = List;
                    RunObject = Page "NPR Scanner - List";
                    ApplicationArea=All;
                }
                action("Upload Program to Scanner")
                {
                    Caption = 'Upload Program to Scanner';
                    Image = "Action";
                    ApplicationArea=All;

                    trigger OnAction()
                    begin
                        cu.UploadProgram2Scanner(Rec);
                    end;
                }
            }
        }
    }

    var
        cu: Codeunit "NPR Scanner - Functions";
}

