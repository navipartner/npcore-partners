xmlport 6014484 "NPR Pacsoft Shipment Document"
{
    Caption = 'Pacsoft Shipment Document';
    Direction = Export;
    Encoding = UTF8;
    schema
    {
        tableelement(shipmentdocument; "NPR Shipping Provider Document")
        {
            XmlName = 'data';
            textelement(sender)
            {
                textattribute(sndid)
                {

                    trigger OnBeforePassVariable()
                    begin
                        sndid := PacsoftSetup."Sender QuickID";
                    end;
                }
                textelement(sendername)
                {
                    XmlName = 'val';
                    textattribute(sendernameattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            sendernameattr := 'name';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        if sndid = '' then
                            sendername := PacsoftMgt.HandleSpecialChars(CompanyInfo.Name);
                        if sendername = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(senderaddr1)
                {
                    XmlName = 'val';
                    textattribute(senderaddr1attr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            senderaddr1attr := 'address1';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        if sndid = '' then
                            senderaddr1 := PacsoftMgt.HandleSpecialChars(CompanyInfo.Address);
                        if senderaddr1 = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(senderaddr2)
                {
                    XmlName = 'val';
                    textattribute(senderaddr2attr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            senderaddr2attr := 'address2';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        if sndid = '' then
                            senderaddr2 := PacsoftMgt.HandleSpecialChars(CompanyInfo."Address 2");
                        if senderaddr2 = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(senderzip)
                {
                    XmlName = 'val';
                    textattribute(senderzipattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            senderzipattr := 'zipcode';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        if sndid = '' then
                            senderzip := PacsoftMgt.HandleSpecialChars(CompanyInfo."Post Code");
                        if senderzip = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(sendercity)
                {
                    XmlName = 'val';
                    textattribute(sendercityattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            sendercityattr := 'city';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        if sndid = '' then
                            sendercity := PacsoftMgt.HandleSpecialChars(CompanyInfo.City);
                        if sendercity = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(sendercountry)
                {
                    XmlName = 'val';
                    textattribute(sendercountryattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            sendercountryattr := 'country';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        if sndid = '' then
                            sendercountry := PacsoftMgt.HandleSpecialChars(CompanyInfo."Country/Region Code");
                        if sendercountry = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(sendercontact)
                {
                    XmlName = 'val';
                    textattribute(sendercontactattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            sendercontactattr := 'contact';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        if sndid = '' then
                            sendercontact := PacsoftMgt.HandleSpecialChars(CompanyInfo."Ship-to Contact");
                        if sendercontact = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(senderphone)
                {
                    XmlName = 'val';
                    textattribute(senderphoneattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            senderphoneattr := 'phone';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        if sndid = '' then
                            senderphone := PacsoftMgt.HandleSpecialChars(CompanyInfo."Phone No.");
                        if senderphone = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(senderfax)
                {
                    XmlName = 'val';
                    textattribute(senderfaxattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            senderfaxattr := 'fax';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        if sndid = '' then
                            senderfax := PacsoftMgt.HandleSpecialChars(CompanyInfo."Fax No.");
                        if senderfax = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(sendervat)
                {
                    XmlName = 'val';
                    textattribute(sendervatattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            sendervatattr := 'vatno';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        if sndid = '' then
                            sendervat := PacsoftMgt.HandleSpecialChars(CompanyInfo."VAT Registration No.");
                        if sendervat = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(senderemail)
                {
                    XmlName = 'val';
                    textattribute(senderemailattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            senderemailattr := 'email';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        if sndid = '' then
                            senderemail := PacsoftMgt.HandleSpecialChars(CompanyInfo."E-Mail");
                        if senderemail = '' then
                            currXMLport.Skip();
                    end;
                }
            }
            textelement(receiver)
            {
                textattribute(rcvid)
                {

                    trigger OnBeforePassVariable()
                    begin
                        rcvid := PacsoftMgt.HandleSpecialChars(ShipmentDocument."Receiver ID");
                    end;
                }
                textelement(rcvname)
                {
                    XmlName = 'val';
                    textattribute(rcvnameattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            rcvnameattr := 'name';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        rcvname := PacsoftMgt.HandleSpecialChars(ShipmentDocument.Name);
                        if rcvname = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(rcvaddr1)
                {
                    XmlName = 'val';
                    textattribute(rcvaddr1attr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            rcvaddr1attr := 'address1';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        rcvaddr1 := PacsoftMgt.HandleSpecialChars(ShipmentDocument.Address);
                        if rcvaddr1 = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(rcvaddr2)
                {
                    XmlName = 'val';
                    textattribute(rcvaddr2attr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            rcvaddr2attr := 'address2';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        rcvaddr2 := PacsoftMgt.HandleSpecialChars(ShipmentDocument."Address 2");
                        if rcvaddr2 = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(rcvzip)
                {
                    XmlName = 'val';
                    textattribute(rcvzipattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            rcvzipattr := 'zipcode';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        rcvzip := PacsoftMgt.HandleSpecialChars(ShipmentDocument."Post Code");
                        if rcvzip = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(rcvcity)
                {
                    XmlName = 'val';
                    textattribute(rcvcityattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            rcvcityattr := 'city';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        rcvcity := PacsoftMgt.HandleSpecialChars(ShipmentDocument.City);
                        if rcvcity = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(rcvstate)
                {
                    XmlName = 'val';
                    textattribute(rcvstateattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            rcvstateattr := 'state';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        rcvstate := PacsoftMgt.HandleSpecialChars(ShipmentDocument.County);
                        if rcvstate = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(rcvcountry)
                {
                    XmlName = 'val';
                    textattribute(rcvcountryattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            rcvcountryattr := 'country';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        rcvcountry := PacsoftMgt.HandleSpecialChars(ShipmentDocument."Country/Region Code");
                        if rcvcountry = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(rcvcontact)
                {
                    XmlName = 'val';
                    textattribute(rcvcontactattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            rcvcontactattr := 'contact';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        rcvcontact := PacsoftMgt.HandleSpecialChars(ShipmentDocument.Contact);
                        if rcvcontact = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(rcvphone)
                {
                    XmlName = 'val';
                    textattribute(rcvphoneattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            rcvphoneattr := 'phone';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        rcvphone := PacsoftMgt.HandleSpecialChars(ShipmentDocument."Phone No.");
                        if rcvphone = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(rcvfax)
                {
                    XmlName = 'val';
                    textattribute(rcvfaxattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            rcvfaxattr := 'fax';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        rcvfax := PacsoftMgt.HandleSpecialChars(ShipmentDocument."Fax No.");
                        if rcvfax = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(rcvvat)
                {
                    XmlName = 'val';
                    textattribute(rcvvatattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            rcvvatattr := 'vatno';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        rcvvat := PacsoftMgt.HandleSpecialChars(ShipmentDocument."VAT Registration No.");
                        if rcvvat = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(rcvemail)
                {
                    XmlName = 'val';
                    textattribute(rcvemailattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            rcvemailattr := 'email';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        rcvemail := PacsoftMgt.HandleSpecialChars(ShipmentDocument."E-Mail");
                        OnAfterBeforePassVariableRCVemail(ShipmentDocument, rcvemail);
                        if rcvemail = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(rcvsms)
                {
                    XmlName = 'val';
                    textattribute(rcvsmsattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            rcvsmsattr := 'sms';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        rcvsms := PacsoftMgt.HandleSpecialChars(ShipmentDocument."SMS No.");
                        if rcvsms = '' then
                            currXMLport.Skip();
                    end;
                }
                trigger OnBeforePassVariable()
                begin
                    if ShipmentDocument."Receiver ID" = '' then
                        currXMLport.Skip();
                end;
            }
            textelement(dl_receiver)
            {
                XmlName = 'receiver';
                textattribute(dl_rcvid)
                {
                    XmlName = 'rcvid';

                    trigger OnBeforePassVariable()
                    begin
                        dl_rcvid := PacsoftMgt.HandleSpecialChars(ShipmentDocument."Delivery Location");
                    end;
                }
                textelement(dl_rcvname)
                {
                    XmlName = 'val';
                    textattribute(dl_rcvnameattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            dl_rcvnameattr := 'name';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        dl_rcvname := PacsoftMgt.HandleSpecialChars(ShipmentDocument."Ship-to Name");
                        if dl_rcvname = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(dl_rcvaddr1)
                {
                    XmlName = 'val';
                    textattribute(dl_rcvaddr1attr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            dl_rcvaddr1attr := 'address1';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        dl_rcvaddr1 := PacsoftMgt.HandleSpecialChars(ShipmentDocument."Ship-to Address");
                        if dl_rcvaddr1 = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(dl_rcvaddr2)
                {
                    XmlName = 'val';
                    textattribute(dl_rcvaddr2attr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            dl_rcvaddr2attr := 'address2';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        dl_rcvaddr2 := PacsoftMgt.HandleSpecialChars(ShipmentDocument."Ship-to Address 2");
                        if dl_rcvaddr2 = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(dl_rcvzip)
                {
                    XmlName = 'val';
                    textattribute(dl_rcvzipattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            dl_rcvzipattr := 'zipcode';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        dl_rcvzip := PacsoftMgt.HandleSpecialChars(ShipmentDocument."Ship-to Post Code");
                        if dl_rcvzip = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(dl_rcvcity)
                {
                    XmlName = 'val';
                    textattribute(dl_rcvcityattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            dl_rcvcityattr := 'city';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        dl_rcvcity := PacsoftMgt.HandleSpecialChars(ShipmentDocument."Ship-to City");
                        if dl_rcvcity = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(dl_rcvstate)
                {
                    XmlName = 'val';
                    textattribute(dl_rcvstateattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            dl_rcvstateattr := 'state';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        dl_rcvstate := PacsoftMgt.HandleSpecialChars(ShipmentDocument."Ship-to County");
                        if dl_rcvstate = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(dl_rcvcountry)
                {
                    XmlName = 'val';
                    textattribute(dl_rcvcountryattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            dl_rcvcountryattr := 'country';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        dl_rcvcountry := PacsoftMgt.HandleSpecialChars(ShipmentDocument."Ship-to Country/Region Code");
                        if dl_rcvcountry = '' then
                            currXMLport.Skip();
                    end;
                }

                trigger OnBeforePassVariable()
                begin
                    if (ShipmentDocument."Delivery Location" = '') and (ShipmentDocument."Ship-to Name" = '') and
                     (shipmentdocument."Ship-to Address" = '') and (shipmentdocument."Ship-to Address 2" = '') and
                     (shipmentdocument."Ship-to Post Code" = '') and (shipmentdocument."Ship-to City" = '') then
                        currXMLport.Skip();
                end;
            }
            textelement(shipment)
            {
                textattribute(orderno)
                {

                    trigger OnBeforePassVariable()
                    begin
                        orderno := Format(ShipmentDocument.Reference);
                        OnAfterBeforePassVariableOrderNo(ShipmentDocument, orderno);
                    end;
                }
                textelement(from)
                {
                    XmlName = 'val';
                    textattribute(fromattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            fromattr := 'from';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        from := sndid;
                        if from = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(tofield)
                {
                    XmlName = 'val';
                    textattribute(toattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            toattr := 'to';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        tofield := rcvid;
                        if tofield = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(agentto)
                {
                    XmlName = 'val';
                    textattribute(agenttoattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            agenttoattr := 'agentto';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        agentto := PacsoftMgt.HandleSpecialChars(ShipmentDocument."Delivery Location");
                        if agentto = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(freetext)
                {
                    XmlName = 'val';
                    textattribute(freetextattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            freetextattr := 'freetext1';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        freetext := PacsoftMgt.HandleSpecialChars(ShipmentDocument."Free Text");
                        if freetext = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(ref)
                {
                    XmlName = 'val';
                    textattribute(refattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            refattr := 'reference';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        ref := PacsoftMgt.HandleSpecialChars(ShipmentDocument.Reference);
                        if ref = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(shipdate)
                {
                    XmlName = 'val';
                    textattribute(shipdateattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            shipdateattr := 'shipdate';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        shipdate := PacsoftMgt.HandleSpecialChars(Format(ShipmentDocument."Shipment Date", 0, '<Year4>-<Month,2>-<Day,2>'));
                        if shipdate = '' then
                            currXMLport.Skip();
                    end;
                }
                textelement(service)
                {
                    XmlName = 'service';
                    textattribute(srvid)
                    {
                        XmlName = 'srvid';

                        trigger OnBeforePassVariable()
                        var
                            TempShippingAgentCode: Code[20];
                        begin
                            TempShippingAgentCode := ShipmentDocument."Shipping Agent Code";
                            OnAfterBeforePassVariable(shipmentdocument, TempShippingAgentCode);

                            srvid := PacsoftMgt.HandleSpecialChars(TempShippingAgentCode);
                        end;
                    }
                    textelement(return)
                    {
                        XmlName = 'val';
                        textattribute(returnattr)
                        {
                            XmlName = 'n';

                            trigger OnBeforePassVariable()
                            begin
                                returnattr := 'returnlabel';
                            end;
                        }

                        trigger OnBeforePassVariable()
                        begin
                            if ShipmentDocument."Return Label Both" then
                                return := 'both'
                            else
                                if ShipmentDocument."Return Label" then
                                    return := 'yes'
                                else
                                    return := 'no';
                        end;
                    }
                    textelement(nondeliv)
                    {
                        XmlName = 'val';
                        textattribute(nondelivattr)
                        {
                            XmlName = 'n';

                            trigger OnBeforePassVariable()
                            begin
                                nondelivattr := 'nondeliverable';
                            end;
                        }

                        trigger OnBeforePassVariable()
                        begin
                            if ShipmentDocument.Undeliverable = ShipmentDocument.Undeliverable::RETURN then
                                nondeliv := 'RETURN'
                            else
                                nondeliv := 'ABANDON';
                        end;
                    }
                    tableelement(shipmentdocumentservice; "NPR Pacsoft Shipm. Doc. Serv.")
                    {
                        LinkFields = "Entry No." = FIELD("Entry No."), "Shipping Agent Code" = FIELD("Shipping Agent Code");
                        LinkTable = ShipmentDocument;
                        XmlName = 'addon';
                        SourceTableView = SORTING("Entry No.", "Shipping Agent Code", "Shipping Agent Service Code") WHERE("Shipping Agent Service Code" = FILTER(<> 'ENOT'));
                        textattribute(adnid)
                        {
                            XmlName = 'adnid';

                            trigger OnBeforePassVariable()
                            begin
                                adnid := PacsoftMgt.HandleSpecialChars(ShipmentDocumentService."Shipping Agent Service Code");
                            end;
                        }
                    }
                }
                textelement(container)
                {
                    textattribute(type)
                    {

                        trigger OnBeforePassVariable()
                        begin
                            if (ShipmentDocument."Parcel Qty." = 1) then
                                type := 'parcel';

                            if (ShipmentDocument."Parcel Qty." > 1) and (ShipmentDocument."Parcel Weight" <> 0) then
                                type := 'parcel';

                            if (ShipmentDocument."Parcel Qty." > 1) and (ShipmentDocument."Parcel Weight" = 0) then
                                type := 'totals';
                        end;
                    }
                    textattribute(measure)
                    {

                        trigger OnBeforePassVariable()
                        begin
                            if (ShipmentDocument."Parcel Qty." = 1) then
                                measure := ''
                            else
                                measure := 'totals';
                        end;
                    }
                    textelement(copies)
                    {
                        XmlName = 'val';
                        textattribute(copiesattr)
                        {
                            XmlName = 'n';

                            trigger OnBeforePassVariable()
                            begin
                                copiesattr := 'copies';
                            end;
                        }

                        trigger OnBeforePassVariable()
                        begin
                            copies := Format(ShipmentDocument."Parcel Qty.");
                            if copies = '' then
                                currXMLport.Skip();
                        end;
                    }
                    textelement(marking)
                    {
                        XmlName = 'val';
                        textattribute(markingattr)
                        {
                            XmlName = 'n';

                            trigger OnBeforePassVariable()
                            begin
                                markingattr := 'marking';
                            end;
                        }

                        trigger OnBeforePassVariable()
                        begin
                            marking := PacsoftMgt.HandleSpecialChars(ShipmentDocument.Marking);
                            if marking = '' then
                                currXMLport.Skip();
                        end;
                    }
                    textelement(package)
                    {
                        XmlName = 'val';
                        textattribute(packageattr)
                        {
                            XmlName = 'n';

                            trigger OnBeforePassVariable()
                            begin
                                packageattr := 'packagecode';
                            end;
                        }

                        trigger OnBeforePassVariable()
                        begin
                            package := ShipmentDocument."Package Code";
                            if package = '' then
                                currXMLport.Skip();
                        end;
                    }
                    textelement(weight)
                    {
                        XmlName = 'val';
                        textattribute(weightattr)
                        {
                            XmlName = 'n';

                            trigger OnBeforePassVariable()
                            begin
                                weightattr := 'weight';
                            end;
                        }

                        trigger OnBeforePassVariable()
                        begin
                            weight := Format(ShipmentDocument."Total Weight");
                            if ShipmentDocument."Total Weight" = 0.01 then
                                weight := '';

                            OnAfterBeforePassVariableWeight(weight);

                            if weight = '' then
                                currXMLport.Skip();
                        end;
                    }
                    textelement(volume)
                    {
                        XmlName = 'val';
                        textattribute(volumeattr)
                        {
                            XmlName = 'n';

                            trigger OnBeforePassVariable()
                            begin
                                volumeattr := 'volume';
                            end;
                        }

                        trigger OnBeforePassVariable()
                        begin
                            volume := PacsoftMgt.HandleSpecialChars(ShipmentDocument.Volume);
                            if volume = '' then
                                currXMLport.Skip();
                        end;
                    }
                    textelement(contents)
                    {
                        XmlName = 'val';
                        textattribute(contentsattr)
                        {
                            XmlName = 'n';

                            trigger OnBeforePassVariable()
                            begin
                                contentsattr := 'contents';
                            end;
                        }

                        trigger OnBeforePassVariable()
                        begin
                            contents := PacsoftMgt.HandleSpecialChars(ShipmentDocument.Contents);
                            if contents = '' then
                                currXMLport.Skip();
                        end;
                    }
                }
                textelement(customsdeclaration)
                {
                    textattribute(documents)
                    {

                        trigger OnBeforePassVariable()
                        begin
                            case ShipmentDocument."Customs Document" of
                                ShipmentDocument."Customs Document"::" ":
                                    documents := '';
                                ShipmentDocument."Customs Document"::CN23:
                                    documents := 'CN23';
                                ShipmentDocument."Customs Document"::"Trade Invoice",
                              ShipmentDocument."Customs Document"::"Pro Forma Invoice":
                                    documents := 'PROFORMA';
                            end;
                        end;
                    }
                    textelement(invoicetype)
                    {
                        XmlName = 'val';
                        textattribute(invoicetypeattr)
                        {
                            XmlName = 'n';

                            trigger OnBeforePassVariable()
                            begin
                                invoicetypeattr := 'invoicetype';
                            end;
                        }

                        trigger OnBeforePassVariable()
                        begin
                            case ShipmentDocument."Customs Document" of
                                ShipmentDocument."Customs Document"::" ",
                              ShipmentDocument."Customs Document"::CN23:
                                    invoicetype := '';
                                ShipmentDocument."Customs Document"::"Trade Invoice":
                                    invoicetype := 'STANDARD';
                                ShipmentDocument."Customs Document"::"Pro Forma Invoice":
                                    invoicetype := 'PROFORMA';
                            end;
                            if invoicetype = '' then
                                currXMLport.Skip();
                        end;
                    }
                    textelement(senderorgno)
                    {
                        XmlName = 'val';
                        textattribute(senderorgnoattr)
                        {
                            XmlName = 'n';

                            trigger OnBeforePassVariable()
                            begin
                                senderorgnoattr := 'senderorgno';
                            end;
                        }

                        trigger OnBeforePassVariable()
                        begin
                            senderorgno := PacsoftMgt.HandleSpecialChars(ShipmentDocument."VAT Registration No.");
                            if senderorgno = '' then
                                currXMLport.Skip();
                        end;
                    }
                    textelement(customsunit)
                    {
                        XmlName = 'val';
                        textattribute(customsunitattr)
                        {
                            XmlName = 'n';

                            trigger OnBeforePassVariable()
                            begin
                                customsunitattr := 'customsunit';
                            end;
                        }

                        trigger OnBeforePassVariable()
                        begin
                            customsunit := ShipmentDocument."Customs Currency";
                            if customsunit = '' then
                                currXMLport.Skip();
                        end;
                    }
                    tableelement(customsitemrows; "NPR Pacsoft Customs Item Rows")
                    {
                        LinkFields = "Shipment Document Entry No." = FIELD("Entry No.");
                        LinkTable = ShipmentDocument;
                        XmlName = 'line';
                        SourceTableView = SORTING("Shipment Document Entry No.", "Entry No.");
                        textattribute(lineattr)
                        {
                            XmlName = 'measure';

                            trigger OnBeforePassVariable()
                            begin
                                case CustomsItemRows."Line Information" of
                                    CustomsItemRows."Line Information"::"Specified Per Row":
                                        lineattr := 'total';
                                    CustomsItemRows."Line Information"::"Specified Per Piece":
                                        lineattr := 'unit';
                                end;
                            end;
                        }
                        textelement(statno)
                        {
                            XmlName = 'val';
                            textattribute(statnoattr)
                            {
                                XmlName = 'n';

                                trigger OnBeforePassVariable()
                                begin
                                    statnoattr := 'statno';
                                end;
                            }

                            trigger OnBeforePassVariable()
                            begin
                                statno := PacsoftMgt.HandleSpecialChars(CustomsItemRows."Item Code");
                                if statno = '' then
                                    currXMLport.Skip();
                            end;
                        }
                        textelement(quantity)
                        {
                            XmlName = 'val';
                            textattribute(quantityattr)
                            {
                                XmlName = 'n';

                                trigger OnBeforePassVariable()
                                begin
                                    quantityattr := 'quantity';
                                end;
                            }

                            trigger OnBeforePassVariable()
                            begin
                                quantity := Format(CustomsItemRows.Copies);
                            end;
                        }
                        textelement(customsvalue)
                        {
                            XmlName = 'val';
                            textattribute(customsvalueattr)
                            {
                                XmlName = 'n';

                                trigger OnBeforePassVariable()
                                begin
                                    customsvalueattr := 'customsvalue';
                                end;
                            }

                            trigger OnBeforePassVariable()
                            begin
                                customsvalue := Format(CustomsItemRows."Customs Value");
                            end;
                        }
                        textelement(rowcontents)
                        {
                            XmlName = 'val';
                            textattribute(rowcontentsattr)
                            {
                                XmlName = 'n';

                                trigger OnBeforePassVariable()
                                begin
                                    rowcontentsattr := 'contents';
                                end;
                            }

                            trigger OnBeforePassVariable()
                            begin
                                rowcontents := PacsoftMgt.HandleSpecialChars(CustomsItemRows.Content);
                                if rowcontents = '' then
                                    currXMLport.Skip();
                            end;
                        }
                        textelement(sourcecountry)
                        {
                            XmlName = 'val';
                            textattribute(sourcecountryattr)
                            {
                                XmlName = 'n';

                                trigger OnBeforePassVariable()
                                begin
                                    sourcecountryattr := 'sourcecountry';
                                end;
                            }

                            trigger OnBeforePassVariable()
                            begin
                                sourcecountry := PacsoftMgt.HandleSpecialChars(CustomsItemRows."Country of Origin");
                                if sourcecountry = '' then
                                    currXMLport.Skip();
                            end;
                        }
                    }
                }
                textelement(ufonline)
                {
                    textelement(option)
                    {
                        textattribute(optid)
                        {

                            trigger OnBeforePassVariable()
                            begin
                                if ShipmentDocument."Send Link To Print" then
                                    if ShipmentDocument."Return Label" then
                                        optid := 'LNKPRTR'
                                    else
                                        optid := 'LNKPRTN';
                            end;
                        }
                        textelement(sendemail)
                        {
                            XmlName = 'val';
                            textattribute(sendemailattr)
                            {
                                XmlName = 'n';

                                trigger OnBeforePassVariable()
                                begin
                                    sendemailattr := 'sendemail';
                                end;
                            }

                            trigger OnBeforePassVariable()
                            begin
                                if ShipmentDocument."Send Link To Print" then
                                    sendemail := 'YES';
                            end;
                        }
                        textelement(mailfrom)
                        {
                            XmlName = 'val';
                            textattribute(mailfromattr)
                            {
                                XmlName = 'n';

                                trigger OnBeforePassVariable()
                                begin
                                    mailfromattr := 'from';
                                end;
                            }

                            trigger OnBeforePassVariable()
                            begin
                                if ShipmentDocument."Send Link To Print" then
                                    mailfrom := CompanyInfo."E-Mail";
                            end;
                        }
                        textelement(mailto)
                        {
                            XmlName = 'val';
                            textattribute(mailtoattr)
                            {
                                XmlName = 'n';

                                trigger OnBeforePassVariable()
                                begin
                                    mailtoattr := 'to';
                                end;
                            }

                            trigger OnBeforePassVariable()
                            begin
                                if ShipmentDocument."Send Link To Print" then
                                    mailto := ShipmentDocument."E-Mail";
                            end;
                        }
                        textelement(mailmessage)
                        {
                            XmlName = 'val';
                            textattribute(mailmessageattr)
                            {
                                XmlName = 'n';

                                trigger OnBeforePassVariable()
                                begin
                                    mailmessageattr := 'message';
                                end;
                            }

                            trigger OnBeforePassVariable()
                            begin
                                if ShipmentDocument."Send Link To Print" then
                                    mailmessage := PacsoftSetup."Link to Print Message";
                            end;
                        }
                    }

                    trigger OnBeforePassVariable()
                    begin
                        if not ShipmentDocument."Send Link To Print" then
                            currXMLport.Skip();
                    end;
                }
                textelement(ufonline2)
                {
                    XmlName = 'ufonline';
                    textelement(option2)
                    {
                        XmlName = 'option';
                        textattribute(optid2)
                        {
                            XmlName = 'optid';

                            trigger OnBeforePassVariable()
                            var
                                PacsoftShipmentDocServices: Record "NPR Pacsoft Shipm. Doc. Serv.";
                            begin
                                PacsoftShipmentDocServices.SetRange("Entry No.", ShipmentDocument."Entry No.");
                                PacsoftShipmentDocServices.SetRange("Shipping Agent Code", ShipmentDocument."Shipping Agent Code");
                                PacsoftShipmentDocServices.SetRange("Shipping Agent Service Code", PacsoftSetup."Shipping Agent Services Code");
                                if PacsoftShipmentDocServices.FindFirst() then
                                    optid2 := PacsoftSetup."Shipping Agent Services Code";
                            end;
                        }
                        textelement(mailfrom2)
                        {
                            XmlName = 'val';
                            textattribute(mailfromattr2)
                            {
                                XmlName = 'n';

                                trigger OnBeforePassVariable()
                                begin
                                    mailfromattr2 := 'from';
                                end;
                            }

                            trigger OnBeforePassVariable()
                            begin
                                if optid2 <> '' then
                                    mailfrom2 := CompanyInfo."E-Mail";
                            end;
                        }
                        textelement(mailto2)
                        {
                            XmlName = 'val';
                            textattribute(mailtoattr2)
                            {
                                XmlName = 'n';

                                trigger OnBeforePassVariable()
                                begin
                                    mailtoattr2 := 'to';
                                end;
                            }

                            trigger OnBeforePassVariable()
                            begin
                                if optid2 <> '' then
                                    mailto2 := ShipmentDocument."E-Mail";
                            end;
                        }
                        textelement(mailmessage2)
                        {
                            XmlName = 'val';
                            textattribute(mailmessageattr2)
                            {
                                XmlName = 'n';

                                trigger OnBeforePassVariable()
                                begin
                                    mailmessageattr2 := 'message';
                                end;
                            }

                            trigger OnBeforePassVariable()
                            begin
                                if ShipmentDocument."Send Link To Print" then
                                    mailmessage := PacsoftSetup."Link to Print Message";
                            end;
                        }
                    }
                    trigger OnBeforePassVariable()
                    var
                        PacsoftShipmentDocServices: Record "NPR Pacsoft Shipm. Doc. Serv.";
                    begin
                        PacsoftShipmentDocServices.SetRange("Entry No.", ShipmentDocument."Entry No.");
                        PacsoftShipmentDocServices.SetRange("Shipping Agent Code", ShipmentDocument."Shipping Agent Code");
                        PacsoftShipmentDocServices.SetRange("Shipping Agent Service Code", PacsoftSetup."Shipping Agent Services Code");
                        if PacsoftShipmentDocServices.Isempty() then
                            currXMLport.Skip();
                    end;
                }
            }

            textelement(Returnshipment)
            {
                XmlName = 'shipment';
                textattribute(Returnorderno)
                {
                    XmlName = 'orderno';
                    trigger OnBeforePassVariable()
                    begin
                        if Showreturn then
                            Returnorderno := FORMAT(ShipmentDocument."External Document No.");
                    end;
                }
                textelement(Returnfrom)
                {
                    XmlName = 'val';
                    textattribute(Returnfromattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            if Showreturn then
                                Returnfromattr := 'from';
                        end;
                    }
                    trigger OnBeforePassVariable()
                    begin
                        if Showreturn then
                            Returnfrom := sndid;
                    end;
                }
                textelement(Returntofield)
                {
                    XmlName = 'val';
                    textattribute(Returntoattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            if Showreturn then
                                Returntoattr := 'to';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        if Showreturn then begin
                            Returntofield := rcvid;

                            if dl_rcvid <> '' then
                                Returntofield := dl_rcvid;
                        end;
                    end;
                }

                textelement(Returnagentto)
                {
                    XmlName = 'val';
                    textattribute(Returnagenttoattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            if Showreturn then
                                Returnagenttoattr := 'agentto';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        if Showreturn then
                            Returnagentto := PacsoftMgt.HandleSpecialChars(ShipmentDocument."Delivery Location");
                    end;
                }

                textelement(Returnfreetext)
                {
                    XmlName = 'val';
                    textattribute(Returnfreetextattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            if Showreturn then
                                Returnfreetextattr := 'freetext1';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        if Showreturn then
                            Returnfreetext := PacsoftMgt.HandleSpecialChars(ShipmentDocument."Free Text");
                    end;
                }

                textelement(Returnref)
                {
                    XmlName = 'val';
                    textattribute(Returnrefattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            if Showreturn then
                                Returnrefattr := 'reference';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        if Showreturn then
                            Returnref := PacsoftMgt.HandleSpecialChars(ShipmentDocument.Reference);
                    end;
                }

                textelement(Returnshipdate)
                {
                    XmlName = 'val';
                    textattribute(Returnshipdateattr)
                    {
                        XmlName = 'n';

                        trigger OnBeforePassVariable()
                        begin
                            if Showreturn then
                                Returnshipdateattr := 'shipdate';
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        if Showreturn then
                            Returnshipdate := PacsoftMgt.HandleSpecialChars(FORMAT(ShipmentDocument."Shipment Date", 0, '<Year4>-<Month,2>-<Day,2>'));
                    end;
                }

                textelement(Returnservice)
                {
                    XmlName = 'service';

                    textattribute(Returnsrvid)
                    {
                        XmlName = 'srvid';

                        trigger OnBeforePassVariable()
                        begin
                            if Showreturn then
                                Returnsrvid := PackageShippingAgent."Return shipping Agent Code";
                        end;
                    }

                    textelement(Rretrun)
                    {
                        XmlName = 'val';
                        textattribute(Rreturnattr)
                        {
                            XmlName = 'n';

                            trigger OnBeforePassVariable()
                            begin
                                Rreturnattr := 'returnlabel';
                            end;
                        }

                        trigger OnBeforePassVariable()
                        begin
                            if Showreturn then
                                Rretrun := 'no';
                        end;
                    }
                }

                textelement(Returncontainer)
                {
                    XmlName = 'container';

                    textattribute(Returntype)
                    {
                        XmlName = 'type';

                        trigger OnBeforePassVariable()
                        begin
                            if Showreturn then begin
                                if (ShipmentDocument."Parcel Qty." = 1) then
                                    Returntype := 'parcel';

                                if (ShipmentDocument."Parcel Qty." > 1) AND (ShipmentDocument."Parcel Weight" <> 0) then
                                    Returntype := 'parcel';

                                if (ShipmentDocument."Parcel Qty." > 1) AND (ShipmentDocument."Parcel Weight" = 0) then
                                    Returntype := 'totals';
                            end;
                        end;
                    }

                    textattribute(Returnmeasure)
                    {
                        XmlName = 'measure';

                        trigger OnBeforePassVariable()
                        begin
                            if Showreturn then begin
                                if (ShipmentDocument."Parcel Qty." = 1) then
                                    Returnmeasure := ''
                                else
                                    Returnmeasure := 'totals';
                            end;
                        end;
                    }

                    textelement(Returncopies)
                    {
                        XmlName = 'val';
                        textattribute(Returncopiesattr)
                        {
                            XmlName = 'n';

                            trigger OnBeforePassVariable()
                            begin
                                if Showreturn then
                                    Returncopiesattr := 'copies';
                            end;
                        }

                        trigger OnBeforePassVariable()
                        begin
                            if Showreturn then
                                Returncopies := FORMAT(ShipmentDocument."Parcel Qty.");
                        end;
                    }

                    textelement(Returnmarking)
                    {
                        XmlName = 'val';
                        textattribute(Returnmarkingattr)
                        {
                            XmlName = 'n';

                            trigger OnBeforePassVariable()
                            begin
                                if Showreturn then
                                    Returnmarkingattr := 'marking';
                            end;
                        }

                        trigger OnBeforePassVariable()
                        begin
                            if Showreturn then
                                Returnmarking := PacsoftMgt.HandleSpecialChars(ShipmentDocument.Marking);
                        end;
                    }
                    textelement(Returnpackage)
                    {
                        XmlName = 'val';
                        textattribute(Returnpackageattr)
                        {
                            XmlName = 'n';

                            trigger OnBeforePassVariable()
                            begin
                                if Showreturn then
                                    Returnpackageattr := 'packagecode';
                            end;
                        }

                        trigger OnBeforePassVariable()
                        begin
                            if Showreturn then begin
                                Returnpackage := ShipmentDocument."Package Code";
                                if package = '' then
                                    Returnpackage := 'PC';
                            end;
                        end;
                    }

                    textelement(Returnweight)
                    {
                        XmlName = 'val';
                        textattribute(Returnweightattr)
                        {
                            XmlName = 'n';

                            trigger OnBeforePassVariable()
                            begin
                                if Showreturn then
                                    Returnweightattr := 'weight';
                            end;
                        }

                        trigger OnBeforePassVariable()
                        begin
                            if Showreturn then begin
                                Returnweight := FORMAT(ShipmentDocument."Total Weight");
                                if ShipmentDocument."Total Weight" = 0.01 then
                                    Returnweight := '';

                                if Returnweight = '' then
                                    Returnweight := '1';
                            end;
                        end;
                    }

                    textelement(Returnvolume)
                    {
                        XmlName = 'val';
                        textattribute(Returnvolumeattr)
                        {
                            XmlName = 'n';

                            trigger OnBeforePassVariable()
                            begin
                                if Showreturn then
                                    Returnvolumeattr := 'volume';
                            end;
                        }

                        trigger OnBeforePassVariable()
                        begin
                            if Showreturn then
                                Returnvolume := PacsoftMgt.HandleSpecialChars(ShipmentDocument.Volume);
                        end;
                    }

                    textelement(Returncontents)
                    {
                        XmlName = 'val';
                        textattribute(Returncontentsattr)
                        {
                            XmlName = 'n';

                            trigger OnBeforePassVariable()
                            begin
                                if Showreturn then
                                    Returncontentsattr := 'contents';
                            end;
                        }

                        trigger OnBeforePassVariable()
                        begin
                            if Showreturn then
                                Returncontents := PacsoftMgt.HandleSpecialChars(ShipmentDocument.Contents);
                        end;
                    }
                }

                trigger OnBeforePassVariable()
                begin
                    Showreturn := false;
                    PackageShippingAgent.GET(ShipmentDocument."Shipping Agent Code");
                    if PackageShippingAgent."Return shipping Agent Code" <> '' then
                        Showreturn := true;
                end;
            }
        }
    }

    requestpage
    {
        Caption = 'Pacsoft Shipment Document';

        layout
        {
        }

        actions
        {
        }
    }

    trigger OnInitXmlPort()
    begin
        CompanyInfo.Get();
        PacsoftSetup.Get();
    end;

    var
        CompanyInfo: Record "Company Information";
        PacsoftSetup: Record "NPR Shipping Provider Setup";
        PackageShippingAgent: Record "NPR Package Shipping Agent";
        PacsoftMgt: Codeunit "NPR Pacsoft Management";
        Showreturn: Boolean;

    [IntegrationEvent(false, false)]
    local procedure OnAfterBeforePassVariable(ShippingProviderDocument: Record "NPR Shipping Provider Document"; var TempShippingAgentCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterBeforePassVariableOrderNo(ShippingProviderDocument: Record "NPR Shipping Provider Document"; var OrderNo: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterBeforePassVariableRCVemail(ShippingProviderDocument: Record "NPR Shipping Provider Document"; var rcvemail: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterBeforePassVariableWeight(var Weight: Text)
    begin
    end;
}

