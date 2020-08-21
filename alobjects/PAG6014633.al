page 6014633 "GCP Ticket Options"
{
    // NPR5.26/MMV /20160826 CASE 246209 Created page.
    // NPR5.48/JDH /20181109 CASE 334163 Added Object Caption

    Caption = 'Google Cloud Print Ticket Options';
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            field(Color; color)
            {
                ApplicationArea = All;
                Editable = false;

                trigger OnAssistEdit()
                var
                    Value: Text;
                    JSON: Text;
                begin
                    if TryLookupValue('color', Value, JSON) then begin
                        color := Value;
                        ColorJSON := JSON;
                    end;
                end;
            }
            field(PageOrientation; page_orientation)
            {
                ApplicationArea = All;
                Editable = false;

                trigger OnAssistEdit()
                var
                    Value: Text;
                    JSON: Text;
                begin
                    if TryLookupValue('page_orientation', Value, JSON) then begin
                        page_orientation := Value;
                        PageOrtJSON := JSON;
                    end;
                end;
            }
            field(Duplex; duplex)
            {
                ApplicationArea = All;
                Editable = false;

                trigger OnAssistEdit()
                var
                    Value: Text;
                    JSON: Text;
                begin
                    if TryLookupValue('duplex', Value, JSON) then begin
                        duplex := Value;
                        DuplexJSON := JSON;
                    end;
                end;
            }
            field("Media Size"; media_size)
            {
                ApplicationArea = All;
                Editable = false;

                trigger OnAssistEdit()
                var
                    Value: Text;
                    JSON: Text;
                begin
                    if TryLookupValue('media_size', Value, JSON) then begin
                        media_size := Value;
                        SizeJSON := JSON;
                    end;
                end;
            }
        }
    }

    actions
    {
    }

    var
        color: Text;
        page_orientation: Text;
        duplex: Text;
        media_size: Text;
        PrinterJSON: Text;
        ColorJSON: Text;
        PageOrtJSON: Text;
        DuplexJSON: Text;
        SizeJSON: Text;
        ChangedValue: Boolean;

    local procedure TryLookupValue(Attribute: Text; var OutValue: Text; var OutJSON: Text): Boolean
    var
        TempRetailList: Record "Retail List" temporary;
        ShowValue: Text;
        GCPMgt: Codeunit "GCP Mgt.";
        JObject: DotNet JObject;
        i: Integer;
    begin
        case Attribute of
            'color':
                ShowValue := 'type';
            'duplex':
                ShowValue := 'type';
            'page_orientation':
                ShowValue := 'type';
            'media_size':
                ShowValue := 'vendor_id'
            else
                exit(false)
        end;

        if GCPMgt.TryParseJSON(PrinterJSON, Attribute + '.option', JObject) then begin
            for i := 0 to JObject.Count - 1 do begin
                TempRetailList.Number += 1;
                TempRetailList.Choice := Format(JObject.Item(i).Item(ShowValue));
                TempRetailList.Value := Format(i);
                TempRetailList.Insert;
            end;

            if PAGE.RunModal(PAGE::"Retail List", TempRetailList) = ACTION::LookupOK then
                if GCPMgt.TryParseJSON(PrinterJSON, Attribute + '.option[' + TempRetailList.Value + ']', JObject) then begin
                    OutValue := TempRetailList.Choice;
                    OutJSON := FormatTicketAttributeJSON(Attribute, JObject);
                    ChangedValue := true;
                    exit(true);
                end;
        end;
    end;

    procedure BuildNewTicketJSON(): Text
    var
        GCPMgt: Codeunit "GCP Mgt.";
    begin
        if ChangedValue then
            exit(GCPMgt.BuildCJT('"1.0"', ColorJSON, '', '', PageOrtJSON, DuplexJSON, '', SizeJSON, '', '', '', '', ''));
    end;

    procedure SetPrinterJSON(JSON: Text)
    begin
        PrinterJSON := JSON;
    end;

    procedure LoadExistingTicketJSON(JSON: Text)
    var
        GCPMgt: Codeunit "GCP Mgt.";
        JObject: DotNet JObject;
    begin
        //Restore already existing blob values to page view. Only modifies blob again if user changes any value.
        if GCPMgt.TryParseJSON(JSON, 'print.color', JObject) then begin
            color := Format(JObject.Item('type'));
            ColorJSON := JObject.ToString();
        end;

        if GCPMgt.TryParseJSON(JSON, 'print.duplex', JObject) then begin
            duplex := Format(JObject.Item('type'));
            DuplexJSON := JObject.ToString();
        end;

        if GCPMgt.TryParseJSON(JSON, 'print.page_orientation', JObject) then begin
            page_orientation := Format(JObject.Item('type'));
            PageOrtJSON := JObject.ToString();
        end;

        if GCPMgt.TryParseJSON(JSON, 'print.media_size', JObject) then begin
            media_size := Format(JObject.Item('vendor_id'));
            SizeJSON := JObject.ToString();
        end;
    end;

    local procedure FormatTicketAttributeJSON(Attribute: Text; var JObject: DotNet JObject) JSON: Text
    var
        GCPMgt: Codeunit "GCP Mgt.";
        AttrJProperty: DotNet npNetJProperty;
        i: Integer;
    begin
        //Elements when retrieving printer info is often a superset of elements required in CJT. This function will format correctly as per the required fields:
        // https://developers.google.com/cloud-print/docs/cdd#cjt

        for i := 0 to JObject.Count - 1 do begin //Can't use .children collection iterators
            if i = 0 then
                AttrJProperty := JObject.First
            else
                AttrJProperty := AttrJProperty.Next;

            if IsValidTicketProperty(Attribute, AttrJProperty.Name) then
                JSON += Format(AttrJProperty) + ',';
        end;

        if JSON <> '' then
            JSON := '{' + CopyStr(JSON, 1, StrLen(JSON) - 1) + '}';

        exit(JSON);
    end;

    local procedure IsValidTicketProperty(Attribute: Text; Property: Text): Boolean
    begin
        case Attribute of
            'color':
                exit(Property in ['vendor_id', 'type']);
            'duplex':
                exit(Property in ['type']);
            'page_orientation':
                exit(Property in ['type']);
            'media_size':
                exit(Property in ['width_microns', 'height_microns', 'is_continuous_feed', 'vendor_id']);
        end;
    end;
}

