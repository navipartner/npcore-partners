report 6014421 "NPR POS Menu Buttons/Actions"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/POS Menu ButtonsActions.rdlc';
    Caption = 'NPR POS Menu Buttons/Actions';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    dataset
    {
        dataitem("POS Menu"; "NPR POS Menu")
        {
            DataItemTableView = SORTING(Code);
            RequestFilterFields = "Code";
            column(Code_POSMenu; Code)
            {
            }
            column(FiltersTxt; FiltersTxt)
            {
            }
            column(ShowParameters; ShowParameters)
            {
            }
            dataitem("POS Menu Button"; "NPR POS Menu Button")
            {
                DataItemLink = "Menu Code" = FIELD(Code);
                DataItemTableView = SORTING("Menu Code", ID);
                column(MenuCode_POSMenuButton; "Menu Code")
                {
                }
                column(ID_POSMenuButton; ID)
                {
                }
                column(Caption_POSMenuButton; Caption)
                {
                }
                column(Tooltip_POSMenuButton; Tooltip)
                {
                }
                column(ActionType_POSMenuButton; "Action Type")
                {
                }
                column(ActionCode_POSMenuButton; "Action Code")
                {
                }
                column(Enabled_POSMenuButton; Enabled)
                {
                }
                column(Blocked_POSMenuButton; GetBooleanText(Blocked))
                {
                }
                dataitem(Param; "NPR POS Parameter Value")
                {
                    DataItemLink = Code = FIELD("Menu Code"), ID = FIELD(ID);
                    DataItemTableView = WHERE("Table No." = CONST(6150701));
                    column(ActionCode_TempParam; "Action Code")
                    {
                    }
                    column(Name_TempParam; Name)
                    {
                    }
                    column(DataType_TempParam; "Data Type")
                    {
                    }
                    column(Value_TempParam; Value)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if "Action Code" = '' then
                            CurrReport.Skip;
                    end;
                }

            }
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(ShowParameters; ShowParameters)
                    {
                        Caption = 'Show Parameters';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Show Parameters field';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            ShowParameters := true;
        end;
    }

    labels
    {
        ReportCaptionLbl = 'List of POS Menu Buttons/Actions';
        FiltersCaptionLbl = 'Filters:';
        PageCaptionLbl = 'Page: %1 of %2';
        POSMenuCaptionLbl = 'POS Menu';
        POSMButtonCaptionLbl = 'POS Menu Button Caption';
        POSMButtonActionTypeCaptionLbl = 'Action Type';
        POSMButtonActionCodeCaptionLbl = 'Action Code';
        POSMButtonBlockedCaptionLbl = 'Blocked';
        POSMButtonEnabledCaptionLbl = 'Enabled';
        POSParaNameCaptionLbl = 'Parameter Name';
        POSParaDataTypesCaptionLbl = 'Parameter Data Type';
        POSParaValuesCaptionLbl = 'Parameter Values';
    }

    trigger OnPreReport()
    begin

        if "POS Menu".GetFilters <> '' then begin
            if FiltersTxt <> '' then
                FiltersTxt += ' | ' + "POS Menu".TableCaption + ' ' + "POS Menu".GetFilters
            else
                FiltersTxt += "POS Menu".TableCaption + ' ' + "POS Menu".GetFilters;
        end;

        if "POS Menu Button".GetFilters <> '' then begin
            if FiltersTxt <> '' then
                FiltersTxt += ' | ' + "POS Menu Button".TableCaption + ' ' + "POS Menu Button".GetFilters
            else
                FiltersTxt += "POS Menu Button".TableCaption + ' ' + "POS Menu Button".GetFilters;
        end;
    end;

    var
        ShowParameters: Boolean;
        FiltersTxt: Text;

    local procedure GetBooleanText(Bool: Boolean): Text
    var
        YesLbl: Label 'Yes';
        NoLbl: Label 'No';
    begin
        if Bool = true then
            exit(YesLbl);

        exit(NoLbl);
    end;
}

