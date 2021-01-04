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
                            ToolTip = 'Specifies the value of the Scanner ID field';
                        }
                        field(Description; Description)
                        {
                            ApplicationArea = All;
                            Importance = Promoted;
                            ToolTip = 'Specifies the value of the Description field';
                        }
                    }
                    group(Control6150619)
                    {
                        ShowCaption = false;
                        field(Type; Type)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Communication I/O field';
                        }
                        field(Port; Port)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Connected on port field';
                        }
                        field("Clear Scanner Option"; "Clear Scanner Option")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Empty scanner option field';
                        }
                        field(Debug; Debug)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Debug field';
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
                            ToolTip = 'Specifies the value of the Path - EXE / DLL directory field';
                        }
                        field("EXE - In"; "EXE - In")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Executing file for reading from scanner field';
                        }
                        field("EXE - Out"; "EXE - Out")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Executing file for writing to scanner field';
                        }
                        field("EXE - Update Scanner"; "EXE - Update Scanner")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Executing file for writing to scanner field';
                        }
                        field("Path - Drop Directory"; "Path - Drop Directory")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Path - Drop directory field';
                        }
                        field("Path - Pickup Directory"; "Path - Pickup Directory")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Path - Pickup directory field';
                        }
                        field("File - Name Type"; "File - Name Type")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the File - Name Type field';
                        }
                        field("File - Name/Prefix"; "File - Name/Prefix")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the File - Name/Prefix field';
                        }
                        field("Import to Server Folder First"; "Import to Server Folder First")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Import to server first field';
                        }
                        field("Local Client Scanner Folder"; "Local Client Scanner Folder")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Local Client scanner folder field';
                        }
                        field("File - After"; "File - After")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the File after reading field';
                        }
                        field("File - Backup Directory"; "File - Backup Directory")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Path to backup files field';
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
                            ToolTip = 'Specifies the value of the Decimal point field';
                        }
                        field("Leading Decimals"; "Leading Decimals")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Number of decimals field';
                        }
                        group("Before Communication")
                        {
                            Caption = 'Before Communication';
                            field("File - Line Skip Pre"; "File - Line Skip Pre")
                            {
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the Skip lines before reading data field';
                            }
                            field("Placement Popup"; "Placement Popup")
                            {
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the Ask: Counting position field';
                            }
                            field("Alt. Import Codeunit"; "Alt. Import Codeunit")
                            {
                                ApplicationArea = All;
                                Caption = 'Alt. Import Codeunit';
                                ToolTip = 'Specifies the value of the Alt. Import Codeunit field';
                            }
                        }
                    }
                    group("Field Format")
                    {
                        Caption = 'Field Format';
                        field("Field Type"; "Field Type")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Field Length Type field';
                        }
                        field("Line Type"; "Line Type")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Line Type field';
                        }
                        field("Record Field Sep."; "Record Field Sep.")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Field separator string field';
                        }
                        field("Prefix Length"; "Prefix Length")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Prefix length field';
                        }
                        field("Scanning End String"; "Scanning End String")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the End scanning string field';
                        }
                        group("Weight Integration")
                        {
                            Caption = 'Weight Integration';
                            field("Weight - No. of MA Samples"; "Weight - No. of MA Samples")
                            {
                                ApplicationArea = All;
                                ToolTip = 'Specifies the value of the Weight - No. of MA Samples field';
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
                            ToolTip = 'Specifies the value of the FTP Download to Server Folder field';
                        }
                        field("FTP Site address"; "FTP Site address")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the FTP Site address field';
                        }
                        field("FTP Filename"; "FTP Filename")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the FTP Filename field';
                        }
                        field("FTP Username"; "FTP Username")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the FTP Username field';
                        }
                        field("FTP Password"; "FTP Password")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the FTP Password field';
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
                    ApplicationArea = All;
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
                    ApplicationArea = All;
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the List action';
                }
                action("Upload Program to Scanner")
                {
                    Caption = 'Upload Program to Scanner';
                    Image = "Action";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Upload Program to Scanner action';

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

