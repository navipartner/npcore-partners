dotnet
{
    assembly("System.Xml")
    {
        Version = '4.0.0.0';
        Culture = 'neutral';
        PublicKeyToken = 'b77a5c561934e089';

        type("System.Xml.XmlDocument"; "NPRNetXmlDocument")
        {
        }

        type("System.Xml.XmlNodeList"; "NPRNetXmlNodeList")
        {
        }

        type("System.Xml.XmlNode"; "NPRNetXmlNode")
        {
        }
    }

    assembly("System")
    {
        Version = '4.0.0.0';
        Culture = 'neutral';
        PublicKeyToken = 'b77a5c561934e089';

        type("System.Diagnostics.Process"; "NPRNetProcess")
        {
        }

        type("System.Diagnostics.ProcessStartInfo"; "NPRNetProcessStartInfo")
        {
        }

        type("System.Net.NetworkCredential"; "NPRNetNetworkCredential")
        {
        }

        type("System.Net.HttpWebRequest"; "NPRNetHttpWebRequest")
        {
        }

        type("System.Net.HttpWebResponse"; "NPRNetHttpWebResponse")
        {
        }

        type("System.Uri"; "NPRNetUri")
        {
        }

        type("System.Net.WebException"; "NPRNetWebException")
        {
        }

        type("System.Net.WebExceptionStatus"; "NPRNetWebExceptionStatus")
        {
        }

        type("System.Net.HttpStatusCode"; "NPRNetHttpStatusCode")
        {
        }

        type("System.Text.RegularExpressions.Regex"; "NPRNetRegex")
        {
        }

        type("System.Collections.Specialized.NameValueCollection"; "NPRNetNameValueCollection")
        {
        }

        type("System.Security.Cryptography.X509Certificates.X509Certificate2"; "NPRNetX509Certificate2")
        {
        }
    }

    assembly("mscorlib")
    {
        Version = '4.0.0.0';
        Culture = 'neutral';
        PublicKeyToken = 'b77a5c561934e089';

        type("System.Reflection.Assembly"; "NPRNetAssembly")
        {
        }

        type("System.String"; "NPRNetString")
        {
        }

        type("System.IO.Stream"; "NPRNetStream")
        {
        }

        type("System.IO.StreamReader"; "NPRNetStreamReader")
        {
        }

        type("System.IO.File"; "NPRNetFile")
        {
        }

        type("System.IO.StreamWriter"; "NPRNetStreamWriter")
        {
        }

        type("System.Text.Encoding"; "NPRNetEncoding")
        {
        }

        type("System.IO.BinaryReader"; "NPRNetBinaryReader")
        {
        }

        type("System.Convert"; "NPRNetConvert")
        {
        }

        type("System.Array"; "NPRNetArray")
        {
        }

        type("System.Char"; "NPRNetChar")
        {
        }

        type("System.Globalization.CultureInfo"; "NPRNetCultureInfo")
        {
        }

        type("System.IO.MemoryStream"; "NPRNetMemoryStream")
        {
        }

        type("System.Type"; "NPRNetType")
        {
        }

        type("System.TimeSpan"; "NPRNetTimeSpan")
        {
        }

        type("System.BitConverter"; "NPRNetBitConverter")
        {
        }

        type("System.Collections.Generic.Dictionary`2"; "NPRNetDictionary_Of_T_U")
        {
        }

        type("System.Collections.Generic.List`1"; "NPRNetList_Of_T")
        {
        }

        type("System.DateTime"; "NPRNetDateTime")
        {
        }

        type("System.Collections.Generic.IEnumerator`1"; "NPRNetIEnumerator_Of_T")
        {
        }

        type("System.Collections.IEnumerator"; "NPRNetIEnumerator")
        {
        }

        type("System.IO.StringReader"; "NPRNetStringReader")
        {
        }

        type("System.Exception"; "NPRNetException")
        {
        }

        type("System.TimeZoneInfo"; "NPRNetTimeZoneInfo")
        {
        }

        type("System.Security.Cryptography.HMACSHA256"; "NPRNetHMACSHA256")
        {
        }

        type("System.Security.Cryptography.SHA256Managed"; "NPRNetSHA256Managed")
        {
        }

        type("System.Security.Cryptography.RSACryptoServiceProvider"; "NPRNetRSACryptoServiceProvider")
        {
        }

        type("System.Security.Cryptography.CryptoConfig"; "NPRNetCryptoConfig")
        {
        }
    }

    assembly("NaviPartner.Retail.Nav")
    {
        Version = '5.0.398.0';
        Culture = 'neutral';
        PublicKeyToken = '909fa1bba7619e33';

        type("NaviPartner.Retail.Nav.ObjectModel.Model"; "NPRNetModel")
        {
        }

        type("NaviPartner.Retail.Nav.ObjectModel.Control"; "NPRNetControl")
        {
        }

        type("NaviPartner.Retail.Nav.ObjectModel.ControlFactory"; "NPRNetControlFactory")
        {
        }

        type("NaviPartner.Retail.Nav.ObjectModel.Panel"; "NPRNetPanel")
        {
        }

        type("NaviPartner.Retail.Nav.ObjectModel.Label"; "NPRNetLabel")
        {
        }
    }

    assembly("Spire.Barcode")
    {
        Version = '1.2.2.21040';
        Culture = 'neutral';
        PublicKeyToken = '663f351905198cb3';

        type("Spire.Barcode.BarCodeType"; "NPRNetBarCodeType")
        {
        }

        type("Spire.Barcode.BarcodeSettings"; "NPRNetBarcodeSettings")
        {
        }

        type("Spire.Barcode.BarCodeGenerator"; "NPRNetBarCodeGenerator")
        {
        }
    }

    assembly("System.Drawing")
    {
        Version = '4.0.0.0';
        Culture = 'neutral';
        PublicKeyToken = 'b03f5f7f11d50a3a';

        type("System.Drawing.Image"; "NPRNetImage")
        {
        }

        type("System.Drawing.Imaging.ImageFormat"; "NPRNetImageFormat")
        {
        }

        type("System.Drawing.ImageConverter"; "NPRNetImageConverter")
        {
        }
    }

    assembly("NaviPartner.Retail.Device.Messaging.PaymentGateway")
    {
        Version = '5.3.992.6';
        Culture = 'neutral';
        PublicKeyToken = '909fa1bba7619e33';

        type("NaviPartner.Retail.Device.Messaging.PaymentGateway.Process.State"; "NPRNetState")
        {
        }

        type("NaviPartner.Retail.Device.Messaging.PaymentGateway.Process.PaymentGatewayProcessRequest"; "NPRNetPaymentGatewayProcessRequest")
        {
        }

        type("NaviPartner.Retail.Device.Messaging.PaymentGateway.Process.PaymentGateway"; "NPRNetPaymentGateway")
        {
        }
    }

    assembly("NaviPartner.Retail.Device")
    {
        Version = '5.0.398.0';
        Culture = 'neutral';
        PublicKeyToken = '909fa1bba7619e33';

        type("NaviPartner.Retail.Device.Envelope.ResponseEnvelope"; "NPRNetResponseEnvelope")
        {
        }

        type("NaviPartner.Retail.Device.Messaging.Method.Request"; "NPRNetRequest")
        {
        }

        type("NaviPartner.Retail.Device.Envelope.RequestEnvelope"; "NPRNetRequestEnvelope")
        {
        }

        type("NaviPartner.Retail.Device.Messaging.ErrorResponse"; "NPRNetErrorResponse")
        {
        }
    }

    assembly("Newtonsoft.Json")
    {
        Culture = 'neutral';
        PublicKeyToken = '30ad4fe6b2a6aeed';

        type("Newtonsoft.Json.Linq.JValue"; "NPRNetJValue")
        {
        }

        type("Newtonsoft.Json.JsonTextReader"; "NPRNetJsonTextReader")
        {
        }
        type("Newtonsoft.Json.DateParseHandling"; "NPRNetDateParseHandling")
        {
        }

        type("Newtonsoft.Json.FloatParseHandling"; "NPRNetFloatParseHandling")
        {
        }

        type("Newtonsoft.Json.Linq.JToken"; "NPRNetJToken")
        {
        }
        type("Newtonsoft.Json.Linq.JObject"; "NPRNetJObject")
        {
        }
        type("Newtonsoft.Json.Linq.JArray"; "NPRNetJArray")
        {
        }
        type("Newtonsoft.Json.JsonConvert"; "NPRNetJsonConvert")
        {
        }
    }
    assembly("NaviPartner.Retail.Device.Messaging.FilePrint")
    {
        Version = '5.0.691.0';
        Culture = 'neutral';
        PublicKeyToken = '909fa1bba7619e33';

        type("NaviPartner.Retail.Device.Messaging.FilePrint.Requests.FilePrintRequest"; "NPRNetFilePrintRequest")
        {
        }

        type("NaviPartner.Retail.Device.Messaging.FilePrint.Responses.FilePrintResponse"; "NPRNetFilePrintResponse")
        {
        }
    }

    assembly("NaviPartner.Retail.Device.Messaging.Print")
    {
        Version = '5.0.398.0';
        Culture = 'neutral';
        PublicKeyToken = '909fa1bba7619e33';

        type("NaviPartner.Retail.Device.Messaging.Print.Responses.PrintResponse"; "NPRNetPrintResponse")
        {
        }

        type("NaviPartner.Retail.Device.Messaging.Print.Requests.PrintRequest"; "NPRNetPrintRequest")
        {
        }
    }

    assembly("System.Core")
    {
        Version = '4.0.0.0';
        Culture = 'neutral';
        PublicKeyToken = 'b77a5c561934e089';

        type("System.Security.Cryptography.SHA256CryptoServiceProvider"; "NPRNetSHA256CryptoServiceProvider")
        {
        }
    }

    assembly("System.Web")
    {
        Version = '4.0.0.0';
        Culture = 'neutral';
        PublicKeyToken = 'b03f5f7f11d50a3a';

        type("System.Web.HttpUtility"; "NPRNetHttpUtility")
        {
        }
    }

    assembly("NaviPartner.Retail.Device.Messaging.CashKeeper")
    {
        Version = '1.0.0.4';
        Culture = 'neutral';
        PublicKeyToken = 'f247894af5fce995';

        type("NaviPartner.Retail.Device.Messaging.CashKeeper.Requests.CashKeeperRequest"; "NPRNetCashKeeperRequest")
        {
        }

        type("NaviPartner.Retail.Device.Messaging.CashKeeper.Process.State+Action"; "NPRNetState_Action")
        {
        }
    }

    assembly("NaviPartner.Retail.Stargate")
    {
        Version = '5.3.745.0';
        Culture = 'neutral';
        PublicKeyToken = '909fa1bba7619e33';

        type("NaviPartner.Retail.Stargate.Envelope.ResponseEnvelope"; "NPRNetResponseEnvelope0")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.Method.Request"; "NPRNetRequest0")
        {
        }

        type("NaviPartner.Retail.Stargate.Envelope.RequestEnvelope"; "NPRNetRequestEnvelope0")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.Method.Response"; "NPRNetResponse1")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.ErrorResponse"; "NPRNetErrorResponse0")
        {
        }

        type("NaviPartner.Retail.Stargate.Exceptions.InvalidMethodException"; "NPRNetInvalidMethodException")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.Packaging.Package"; "NPRNetPackage")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.Packaging.PackageRequest"; "NPRNetPackageRequest")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.EmptyResponse"; "NPRNetEmptyResponse")
        {
        }
    }

    assembly("Microsoft.Exchange.WebServices")
    {
        Version = '15.0.0.0';
        Culture = 'neutral';
        PublicKeyToken = '31bf3856ad364e35';

        type("Microsoft.Exchange.WebServices.Data.ExchangeService"; "NPRNetExchangeService")
        {
        }

        type("Microsoft.Exchange.WebServices.Data.ExchangeCredentials"; "NPRNetExchangeCredentials")
        {
        }

        type("Microsoft.Exchange.WebServices.Data.ExchangeVersion"; "NPRNetExchangeVersion")
        {
        }

        type("Microsoft.Exchange.WebServices.Data.Appointment"; "NPRNetAppointment")
        {
        }

        type("Microsoft.Exchange.WebServices.Data.ItemId"; "NPRNetItemId")
        {
        }

        type("Microsoft.Exchange.WebServices.Data.MessageBody"; "NPRNetMessageBody")
        {
        }

        type("Microsoft.Exchange.WebServices.Data.BodyType"; "NPRNetBodyType")
        {
        }

        type("Microsoft.Exchange.WebServices.Data.StringList"; "NPRNetStringList")
        {
        }

        type("Microsoft.Exchange.WebServices.Data.LegacyFreeBusyStatus"; "NPRNetLegacyFreeBusyStatus")
        {
        }

        type("Microsoft.Exchange.WebServices.Data.PropertySet"; "NPRNetPropertySet")
        {
        }

        type("Microsoft.Exchange.WebServices.Data.MeetingResponseType"; "NPRNetMeetingResponseType")
        {
        }

        type("Microsoft.Exchange.WebServices.Data.Attendee"; "NPRNetAttendee")
        {
        }

        type("Microsoft.Exchange.WebServices.Data.DeleteMode"; "NPRNetDeleteMode")
        {
        }

        type("Microsoft.Exchange.WebServices.Data.SendCancellationsMode"; "NPRNetSendCancellationsMode")
        {
        }

        type("Microsoft.Exchange.WebServices.Data.SendInvitationsMode"; "NPRNetSendInvitationsMode")
        {
        }

        type("Microsoft.Exchange.WebServices.Data.ConflictResolutionMode"; "NPRNetConflictResolutionMode")
        {
        }

        type("Microsoft.Exchange.WebServices.Data.SendInvitationsOrCancellationsMode"; "NPRNetSendInvitationsOrCancellationsMode")
        {
        }

        type("Microsoft.Exchange.WebServices.Data.EmailMessage"; "NPRNetEmailMessage")
        {
        }

        type("Microsoft.Exchange.WebServices.Data.EmailAddress"; "NPRNetEmailAddress")
        {
        }

        type("Microsoft.Exchange.WebServices.Data.EmailAddressCollection"; "NPRNetEmailAddressCollection")
        {
        }
    }

    assembly("Microsoft.Dynamics.Nav.DocumentReport")
    {
        Culture = 'neutral';
        PublicKeyToken = '31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.DocumentReport.WordReportManager"; "NPRNetWordReportManager")
        {
        }
    }

    assembly("Microsoft.Dynamics.Nav.PdfWriter")
    {
        Culture = 'neutral';
        PublicKeyToken = '31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.PdfWriter.WordToPdf"; "NPRNetWordToPdf")
        {
        }
    }

    assembly("Microsoft.Dynamics.Nav.EwsWrapper")
    {
        Culture = 'neutral';
        PublicKeyToken = '31bf3856ad364e35';

        type("Microsoft.Dynamics.Nav.Exchange.ExchangeServiceWrapper"; "NPRNetExchangeServiceWrapper")
        {
        }
    }

    assembly("NaviPartner.Retail.Stargate.Messaging.OPOS")
    {
        Version = '5.3.1181.1';
        Culture = 'neutral';
        PublicKeyToken = '909fa1bba7619e33';

        type("NaviPartner.Retail.Stargate.Messaging.OPOS.Requests.EjectDrawerRequest"; "NPRNetEjectDrawerRequest")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.OPOS.Responses.EjectDrawerResponse"; "NPRNetEjectDrawerResponse")
        {
        }
    }

    assembly("NaviPartner.Retail.Stargate.Messaging.CashKeeper")
    {
        Version = '5.3.745.0';
        Culture = 'neutral';
        PublicKeyToken = 'f247894af5fce995';

        type("NaviPartner.Retail.Stargate.Messaging.CashKeeper.Requests.CashKeeperRequest"; "NPRNetCashKeeperRequest0")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.CashKeeper.Process.State"; "NPRNetState4")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.CashKeeper.Process.State+Action"; "NPRNetState_Action2")
        {
        }
    }

    assembly("NaviPartner.Retail.Stargate.Messaging.Print")
    {
        Version = '5.3.1240.2';
        Culture = 'neutral';
        PublicKeyToken = '909fa1bba7619e33';

        type("NaviPartner.Retail.Stargate.Messaging.Print.Requests.PrintRequest"; "NPRNetPrintRequest0")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.Print.Responses.PrintResponse"; "NPRNetPrintResponse0")
        {
        }
    }

    assembly("NaviPartner.Retail.Stargate.Messaging.FilePrint")
    {
        Version = '5.3.1240.2';
        Culture = 'neutral';
        PublicKeyToken = '909fa1bba7619e33';

        type("NaviPartner.Retail.Stargate.Messaging.FilePrint.Requests.FilePrintRequest"; "NPRNetFilePrintRequest0")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.FilePrint.Requests.FilePrintRequest+PrintMethod"; "NPRNetFilePrintRequest_PrintMethod")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.FilePrint.Responses.FilePrintResponse"; "NPRNetFilePrintResponse0")
        {
        }
    }

    assembly("NaviPartner.Retail.Device.Messaging.PepperPayment")
    {
        Version = '5.0.398.3';
        Culture = 'neutral';
        PublicKeyToken = '909fa1bba7619e33';

        type("NaviPartner.Retail.Device.Messaging.PepperPayment.Requests.StartWorkshiftRequest"; "NPRNetStartWorkshiftRequest")
        {
        }

        type("NaviPartner.Retail.Device.Messaging.PepperPayment.Responses.StartWorkshiftResponse"; "NPRNetStartWorkshiftResponse")
        {
        }

        type("NaviPartner.Retail.Device.Messaging.PepperPayment.Params.ConfigDriverParam"; "NPRNetConfigDriverParam")
        {
        }

        type("NaviPartner.Retail.Device.Messaging.PepperPayment.Params.OpenParam"; "NPRNetOpenParam")
        {
        }

        type("NaviPartner.Retail.Device.Messaging.PepperPayment.Process.ProcessLabels"; "NPRNetProcessLabels")
        {
        }

        type("NaviPartner.Retail.Device.Messaging.PepperPayment.Requests.TransactionRequest"; "NPRNetTransactionRequest")
        {
        }

        type("NaviPartner.Retail.Device.Messaging.PepperPayment.Responses.TransactionResponse"; "NPRNetTransactionResponse")
        {
        }

        type("NaviPartner.Retail.Device.Messaging.PepperPayment.Results.TrxResult"; "NPRNetTrxResult")
        {
        }

        type("NaviPartner.Retail.Device.Messaging.PepperPayment.Params.TrxParam"; "NPRNetTrxParam")
        {
        }

        type("NaviPartner.Retail.Device.Messaging.PepperPayment.Requests.EndWorkshiftRequest"; "NPRNetEndWorkshiftRequest")
        {
        }

        type("NaviPartner.Retail.Device.Messaging.PepperPayment.Responses.EndWorkshiftResponse"; "NPRNetEndWorkshiftResponse")
        {
        }

        type("NaviPartner.Retail.Device.Messaging.PepperPayment.Requests.AuxRequest"; "NPRNetAuxRequest")
        {
        }

        type("NaviPartner.Retail.Device.Messaging.PepperPayment.Responses.AuxResponse"; "NPRNetAuxResponse")
        {
        }

        type("NaviPartner.Retail.Device.Messaging.PepperPayment.Results.AuxResult"; "NPRNetAuxResult")
        {
        }

        type("NaviPartner.Retail.Device.Messaging.PepperPayment.Params.AuxParam"; "NPRNetAuxParam")
        {
        }

        type("NaviPartner.Retail.Device.Messaging.PepperPayment.Utils.PepperOpCodes"; "NPRNetPepperOpCodes")
        {
        }

        type("NaviPartner.Retail.Device.Messaging.PepperPayment.Requests.FileManagementRequest"; "NPRNetFileManagementRequest")
        {
        }

        type("NaviPartner.Retail.Device.Messaging.PepperPayment.Responses.FileManagementResponse"; "NPRNetFileManagementResponse")
        {
        }
    }

    assembly("NaviPartner.Retail.Stargate.Messaging.PepperPayment")
    {
        Version = '5.3.745.1';
        Culture = 'neutral';
        PublicKeyToken = '909fa1bba7619e33';

        type("NaviPartner.Retail.Stargate.Messaging.PepperPayment.Requests.StartWorkshiftRequest"; "NPRNetStartWorkshiftRequest0")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.PepperPayment.Responses.StartWorkshiftResponse"; "NPRNetStartWorkshiftResponse0")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.PepperPayment.Params.ConfigDriverParam"; "NPRNetConfigDriverParam0")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.PepperPayment.Params.OpenParam"; "NPRNetOpenParam0")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.PepperPayment.Process.ProcessLabels"; "NPRNetProcessLabels0")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.PepperPayment.Requests.TransactionRequest"; "NPRNetTransactionRequest0")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.PepperPayment.Responses.TransactionResponse"; "NPRNetTransactionResponse0")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.PepperPayment.Results.TrxResult"; "NPRNetTrxResult0")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.PepperPayment.Params.TrxParam"; "NPRNetTrxParam0")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.PepperPayment.Requests.EndWorkshiftRequest"; "NPRNetEndWorkshiftRequest0")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.PepperPayment.Responses.EndWorkshiftResponse"; "NPRNetEndWorkshiftResponse0")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.PepperPayment.Requests.AuxRequest"; "NPRNetAuxRequest0")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.PepperPayment.Responses.AuxResponse"; "NPRNetAuxResponse0")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.PepperPayment.Results.AuxResult"; "NPRNetAuxResult0")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.PepperPayment.Params.AuxParam"; "NPRNetAuxParam0")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.PepperPayment.Utils.PepperOpCodes"; "NPRNetPepperOpCodes0")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.PepperPayment.Requests.FileManagementRequest"; "NPRNetFileManagementRequest0")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.PepperPayment.Responses.FileManagementResponse"; "NPRNetFileManagementResponse0")
        {
        }
    }

    assembly("NaviPartner.Retail.Stargate.Messaging.MockEFT")
    {
        Version = '5.3.1350.6';
        Culture = 'neutral';
        PublicKeyToken = '909fa1bba7619e33';

        type("NaviPartner.Retail.Stargate.Messaging.MockEFT.Captions"; "NPRNetCaptions")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.MockEFT.Requests.TransactionRequest"; "NPRNetTransactionRequest1")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.MockEFT.State"; "NPRNetState5")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.MockEFT.Requests.OpenRequest"; "NPRNetOpenRequest")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.MockEFT.Requests.CloseRequest"; "NPRNetCloseRequest")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.MockEFT.Requests.VerifySetupRequest"; "NPRNetVerifySetupRequest")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.MockEFT.Requests.LookupTransactionRequest"; "NPRNetLookupTransactionRequest")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.MockEFT.Requests.VoidRequest"; "NPRNetVoidRequest")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.MockEFT.Requests.BalanceEnquiryRequest"; "NPRNetBalanceEnquiryRequest")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.MockEFT.Requests.ReprintReceiptRequest"; "NPRNetReprintReceiptRequest")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.MockEFT.Requests.GenericRequest"; "NPRNetGenericRequest")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.MockEFT.Responses.GenericResponse"; "NPRNetGenericResponse")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.MockEFT.State+Connection"; "NPRNetState_Connection")
        {
        }
    }

    assembly("NaviPartner.Retail.Stargate.Messaging.PaymentGateway")
    {
        Version = '5.3.1240.0';
        Culture = 'neutral';
        PublicKeyToken = '909fa1bba7619e33';

        type("NaviPartner.Retail.Stargate.Messaging.PaymentGateway.Process.State"; "NPRNetState6")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.PaymentGateway.Process.PaymentGatewayProcessRequest"; "NPRNetPaymentGatewayProcessRequest0")
        {
        }
    }

    assembly("NaviPartner.Retail.Stargate.Messaging.VerifoneVIM")
    {
        Version = '5.0.1835.1';
        Culture = 'neutral';
        PublicKeyToken = '909fa1bba7619e33';

        type("NaviPartner.Retail.Stargate.Messaging.VerifoneVIM.Requests.Transaction.TransactionRequest"; "NPRNetTransactionRequest2")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.VerifoneVIM.Requests.Login.LoginRequest"; "NPRNetLoginRequest")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.VerifoneVIM.Requests.Logout.LogoutRequest"; "NPRNetLogoutRequest")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.VerifoneVIM.Requests.BalanceEnquiry.BalanceEnquiryRequest"; "NPRNetBalanceEnquiryRequest0")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.VerifoneVIM.Requests.Reconciliation.ReconciliationRequest"; "NPRNetReconciliationRequest")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.VerifoneVIM.Requests.TransactionStatus.TransactionStatusRequest"; "NPRNetTransactionStatusRequest")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.VerifoneVIM.Requests.Login.LoginResponse"; "NPRNetLoginResponse")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.VerifoneVIM.Requests.Logout.LogoutResponse"; "NPRNetLogoutResponse")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.VerifoneVIM.Requests.Transaction.TransactionResponse"; "NPRNetTransactionResponse1")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.VerifoneVIM.Requests.TransactionStatus.TransactionStatusResponse"; "NPRNetTransactionStatusResponse")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.VerifoneVIM.Requests.BalanceEnquiry.BalanceEnquiryResponse"; "NPRNetBalanceEnquiryResponse")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.VerifoneVIM.Requests.Reconciliation.ReconciliationResponse"; "NPRNetReconciliationResponse")
        {
        }
    }

    assembly("NaviPartner.Retail.Stargate.Messaging.JSONSerializer")
    {
        Version = '5.0.1791.0';
        Culture = 'neutral';
        PublicKeyToken = '909fa1bba7619e33';

        type("NaviPartner.Retail.Stargate.Messaging.JSONSerializer.Serializer"; "NPRNetSerializer")
        {
        }
    }

    assembly("NaviPartner.Retail.Stargate.Messaging.NETSBAXI")
    {
        Version = '5.0.1917.4';
        Culture = 'neutral';
        PublicKeyToken = '909fa1bba7619e33';

        type("NaviPartner.Retail.Stargate.Messaging.NETSBAXI.Requests.Transaction.TransactionRequest"; "NPRNetTransactionRequest3")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.NETSBAXI.Requests.Open.OpenParameters"; "NPRNetOpenParameters")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.NETSBAXI.Requests.Open.OpenRequest"; "NPRNetOpenRequest0")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.NETSBAXI.Requests.Close.CloseRequest"; "NPRNetCloseRequest0")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.NETSBAXI.Requests.Administration.AdministrationRequest"; "NPRNetAdministrationRequest")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.NETSBAXI.Requests.GetLastResult.GetLastRequest"; "NPRNetGetLastRequest")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.NETSBAXI.Requests.Open.OpenResponse"; "NPRNetOpenResponse")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.NETSBAXI.Requests.Close.CloseResponse"; "NPRNetCloseResponse")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.NETSBAXI.Requests.Transaction.TransactionResponse"; "NPRNetTransactionResponse2")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.NETSBAXI.Requests.Administration.AdministrationResponse"; "NPRNetAdministrationResponse")
        {
        }

        type("NaviPartner.Retail.Stargate.Messaging.NETSBAXI.Requests.GetLastResult.GetLastResponse"; "NPRNetGetLastResponse")
        {
        }
    }

    assembly("Microsoft.Dynamics.Nav.Client.PingPong")
    {
        type("Microsoft.Dynamics.Nav.Client.PingPong.PingPongAddIn"; "NPRMicrosoft.Dynamics.Nav.Client.PingPong")
        {
            IsControlAddIn = true;
        }
    }
    assembly("NavHelper.AssemblyResolver")
    {
        Version = '2.4.0.0';
        Culture = 'neutral';
        PublicKeyToken = 'cc06fd55bdc3ade8';

        type("NavHelper.AssemblyResolver.AssemblyResolver"; "NPRNetAssemblyResolver")
        {
        }
    }

}
