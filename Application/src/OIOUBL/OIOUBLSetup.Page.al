page 6150759 "NPR OIOUBL Setup"
{
    Caption = 'NP OIOUBL Setup';
    PageType = Card;
    SourceTable = "NPR OIOUBL Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;
    DeleteAllowed = false;
    InsertAllowed = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            group(Status)
            {
                ShowCaption = false;
                field(SetupStatus; SetupStatus)
                {
                    ShowCaption = false;
                    StyleExpr = StatusStyle;
                    Editable = false;
                    ApplicationArea = NPRRetail;
                    trigger OnDrillDown()
                    begin
                        if StatsuUpdatePageId <> 0 then begin
                            Page.RunModal(StatsuUpdatePageId);
                            CurrPage.Update(false);
                        end;
                    end;
                }
            }
            group(General)
            {
                Visible = OIOUBLInstalled;
                field(Enabled; Rec.Enabled)
                {
                    ToolTip = 'Specifies if transfer of OIOUBL file thought NaviPartner is enabled';
                    ApplicationArea = NPRRetail;
                    trigger OnValidate()
                    begin
                        SetupStatus := GetSetupStatus();
                    end;
                }
                field("Include PDF Invoice"; Rec."Include PDF Invoice")
                {
                    ToolTip = 'Specifies if a .pdf invoice should be include in the OIOUBL file.';
                    ApplicationArea = NPRRetail;
                }
                field("Include PDF Cr. Memo"; Rec."Include PDF Cr. Memo")
                {
                    ToolTip = 'Specifies if a .pdf credit memo should be include in the OIOUBL file.';
                    ApplicationArea = NPRRetail;
                }
                field("Filename Pattern"; Rec."Filename Pattern")
                {
                    ToolTip = 'Specifies the Filename Pattern to be used for generated OIOUBL files. %1 will be repaced by Document No. %2 will be replaced by Document Type';
                    ApplicationArea = NPRRetail;
                }
                field("Use Nemhandel Lookup"; Rec."Use Nemhandel Lookup")
                {
                    ToolTip = 'Specifies if "VAT Registration No." and "GLN" are validated using the Nemhandel api';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(SetupPages)
            {
                Caption = 'Setup Pages';
                action(DocumentSendingProfiles)
                {
                    Caption = 'Document Sending Profiles';
                    Image = SendElectronicDocument;
                    ToolTip = 'Displays the Document Sending Profiles';
                    ApplicationArea = NPRRetail;
                    Visible = OIOUBLInstalled;
                    trigger OnAction()
                    begin
                        Page.RunModal(Page::"Document Sending Profiles");
                        CurrPage.Update(false);
                    end;
                }
                action(ElectronicDocumentFormats)
                {
                    Caption = 'Electronic Document Formats';
                    Image = ElectronicDoc;
                    ToolTip = 'Displays the Electronic Doucument Formats';
                    ApplicationArea = NPRRetail;
                    Visible = OIOUBLInstalled;
                    trigger OnAction()
                    begin
                        Page.RunModal(Page::"Electronic Document Format");
                        CurrPage.Update(false);
                    end;
                }
            }
            action(ValidateUnitofMeasure)
            {
                Caption = 'Validate Unit of Measures';
                Image = TestDatabase;
                ToolTip = 'Validates the OIOUBL codes on Unit of Measures';
                ApplicationArea = NPRRetail;
                Visible = OIOUBLInstalled;
                trigger OnAction()
                var
                    UnitofMeasureMgt: Codeunit "NPR OIOUBL Unit Of Measure Mgt";
                begin
                    UnitofMeasureMgt.ValidateUnitOfMeasureSetup();
                end;

            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
        OIOUBLInstalled := Rec.IsOIOUBLInstalled();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SetupStatus := GetSetupStatus();
    end;

    var
        StatsuUpdatePageId: Integer;
        OIOUBLInstalled: Boolean;
        NoOIOUBLLbl: Label 'Extension OIOUBL publisher Microsoft is not installed.';
        StatusStyle: Text;
        SetupStatus: Text;

    local procedure GetSetupStatus(): Text
    var
        ElectronicDocumentFormat: Record "Electronic Document Format";
        DocumentSendingProfile: Record "Document Sending Profile";
        AllObjectswithCaption: Record AllObjWithCaption;
        EnvironmentInformation: Codeunit "Environment Information";
        Info: ModuleInfo;
        OIOFormat: Code[20];
        OIOFormatList: List of [Code[20]];
        OIOFormatFilter: Text;
        OIOFormatText: Text;
        SetupReadyLbl: Label 'Transfer OIOUBL through NaviPartner is active';
        NotActivatedLbl: Label 'Transfer OIOUBL through NaviPartner is not enabled';
        NoDocumentFormatLbl: Label 'No %1 using %2 %3 %4 found.', Comment = '%1=Electronic Document Format tablecaption; %2=Objecttype, %3=objectId, %4=object caption';
        NoSendingProfileLbl: Label 'No %1 with %2=%3 is using %4 %5';
        OldOIOUBLAppIdLbl: Label 'f15dfd3b-4489-4616-923f-9e5902395f40';
        OldOIOUBLInstalledLbl: Label 'NP OIOUBL extension is installed. Uninstall NP OIOUBL extension before you can use this OIOUBL feature';
        OrLbl: Label ' or ';
    begin
        StatusStyle := 'Unfavorable';
        StatsuUpdatePageId := Page::"Extension Management";
        if not Rec.IsOIOUBLInstalled() then
            exit(NoOIOUBLLbl);
        if not EnvironmentInformation.IsSaaS() then
            if NavApp.GetModuleInfo(OldOIOUBLAppIdLbl, Info) then
                exit(OldOIOUBLInstalledLbl);
        if not Rec.Enabled then
            exit(NotActivatedLbl);
        ElectronicDocumentFormat.SetRange("Delivery Codeunit ID", Codeunit::"NPR OIOUBL Transfer Service");
        if not ElectronicDocumentFormat.FindSet() then begin
            StatsuUpdatePageId := Page::"Electronic Document Format";
            AllObjectswithCaption.Get(AllObjectswithCaption."Object Type"::Codeunit, Codeunit::"NPR OIOUBL Transfer Service");
            exit(StrSubstNo(NoDocumentFormatLbl, ElectronicDocumentFormat.TableCaption, AllObjectswithCaption."Object Type", AllObjectswithCaption."Object ID", AllObjectswithCaption."Object Caption"));
        end;
        repeat
            if not OIOFormatList.Contains(ElectronicDocumentFormat.Code) then
                OIOFormatList.Add(ElectronicDocumentFormat.Code);
        until ElectronicDocumentFormat.Next() = 0;
        foreach OIOFormat in OIOFormatList do begin
            OIOFormatText += OIOFormat + OrLbl;
            OIOFormatFilter += OIOFormat + '|';
        end;
        OIOFormatText := OIOFormatText.TrimEnd(OrLbl);
        OIOFormatFilter := OIOFormatFilter.TrimEnd('|');

        DocumentSendingProfile.SetRange("Electronic Document", DocumentSendingProfile."Electronic Document"::"Through Document Exchange Service");
        DocumentSendingProfile.SetFilter("Electronic Format", OIOFormatFilter);
        if DocumentSendingProfile.IsEmpty then begin
            StatsuUpdatePageId := Page::"Document Sending Profiles";
            exit(StrSubstNo(NoSendingProfileLbl, DocumentSendingProfile.TableCaption, DocumentSendingProfile.FieldCaption("Electronic Document"), DocumentSendingProfile."Electronic Document"::"Through Document Exchange Service", DocumentSendingProfile.FieldCaption("Electronic Format"), OIOFormatText));
        end;
        StatusStyle := 'Favorable';
        StatsuUpdatePageId := 0;
        exit(SetupReadyLbl);

    end;
}
