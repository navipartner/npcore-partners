report 6014421 "POS Menu Buttons/Actions"
{
    // NPK1.00/JLK /20170605  CASE 279362 Object created
    // NPR5.33/NPKNAV/20170630  CASE 279362 Transport NPR5.33 - 30 June 2017
    // NPR5.38/JLK /20180124  CASE 300892 Removed AL Error on ControlContainer Caption in Request Page
    // NPR5.40/VB  /20180301  CASE 306347 Updated report to reflect the change from BLOB-based temporary-table parameters to physical-table parameters.
    DefaultLayout = RDLC;
    RDLCLayout = './layouts/POS Menu ButtonsActions.rdlc';

    Caption = 'NPR POS Menu Buttons/Actions';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("POS Menu";"POS Menu")
        {
            DataItemTableView = SORTING(Code);
            RequestFilterFields = "Code";
            column(Code_POSMenu;Code)
            {
            }
            column(FiltersTxt;FiltersTxt)
            {
            }
            column(ShowParameters;ShowParameters)
            {
            }
            dataitem("POS Menu Button";"POS Menu Button")
            {
                DataItemLink = "Menu Code"=FIELD(Code);
                DataItemTableView = SORTING("Menu Code",ID);
                column(MenuCode_POSMenuButton;"Menu Code")
                {
                }
                column(ID_POSMenuButton;ID)
                {
                }
                column(Caption_POSMenuButton;Caption)
                {
                }
                column(Tooltip_POSMenuButton;Tooltip)
                {
                }
                column(ActionType_POSMenuButton;"Action Type")
                {
                }
                column(ActionCode_POSMenuButton;"Action Code")
                {
                }
                column(Enabled_POSMenuButton;Enabled)
                {
                }
                column(Blocked_POSMenuButton;GetBooleanText(Blocked))
                {
                }
                dataitem(Param;"POS Parameter Value")
                {
                    DataItemLink = Code=FIELD("Menu Code"),ID=FIELD(ID);
                    DataItemTableView = WHERE("Table No."=CONST(6150701));
                    column(ActionCode_TempParam;"Action Code")
                    {
                    }
                    column(Name_TempParam;Name)
                    {
                    }
                    column(DataType_TempParam;"Data Type")
                    {
                    }
                    column(Value_TempParam;Value)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if "Action Code" = '' then
                          CurrReport.Skip;
                    end;
                }

                trigger OnAfterGetRecord()
                var
                    RecRef: RecordRef;
                    FieldRef: FieldRef;
                begin
                    //-NPR5.40 [306347]
                    //RecRef.GETTABLE("POS Menu Button");
                    //FieldRef := RecRef.FIELD(FIELDNO(Parameters));
                    //TempParam.DELETEALL;
                    //
                    //IF ShowParameters THEN
                    //  LoadFromField(FieldRef,TempParam);
                    //+NPR5.40 [306347]
                end;
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
                    field(ShowParameters;ShowParameters)
                    {
                        Caption = 'Show Parameters';
                    }
                }
            }
        }

        actions
        {
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
        FiltersTxt: Text;
        ShowParameters: Boolean;

    local procedure GetBooleanText(Bool: Boolean): Text
    begin
        if Bool = true then
          exit('Yes');

        exit('No');
    end;
}

