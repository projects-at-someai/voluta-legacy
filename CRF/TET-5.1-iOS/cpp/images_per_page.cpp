/* Page-based image extractor based on PDFlib TET
 *
 * $Id: images_per_page.c,v 1.5 2015/07/24 12:41:17 tm Exp $
 */

#include <iostream>
#include <algorithm>

#include "tet.hpp"

using namespace std;
using namespace pdflib;

namespace
{

/*  global option list */
const wstring globaloptlist = L"searchpath={{../data}}";

/* document-specific  option list */
const wstring docoptlist = L"";

/* page-specific option list, e.g.
 * "imageanalysis={merge={gap=1} smallimages={maxwidth=20}}"
 */
const wstring pageoptlist = L"";

void report_image_info(TET& tet, int doc, int imageid);

wstring get_wstring(const TET& tet, const string & utf8_string);

bool ends_with(wstring const & value, wstring const & ending)
{
    return ending.size() <= value.size() ?
        equal(ending.rbegin(), ending.rend(), value.rbegin()) : false;
}

} // end of anonymous namespace

int main(int argc, char **argv)
{
    int pageno = 0;

    if (argc != 2)
    {
        wcerr << L"usage: images_per_page <filename>" << endl;
        return 2;
    }

    try
    {
        TET tet;

        /*
         * Prepare wide character representation of outfilebase for use in
         * option list, under the assumption that the program arguments are
         * encoded as UTF-8.
         */
        wstring woutfilebase(get_wstring(tet, argv[1]));

        /* strip .pdf suffix if present */
        if (ends_with(woutfilebase, L".pdf")
                || ends_with(woutfilebase, L".PDF"))
        {
            woutfilebase.erase(woutfilebase.length() - 4);
        }

        tet.set_option(globaloptlist);

        /*
         * Caution: For simplicity we assume that the program arguments are
         * encoded as UTF-8, which might not be true in all cases!
         */
        wstring const doc_name(get_wstring(tet, string(argv[1])));
        int const doc = tet.open_document(doc_name, docoptlist);

        if (doc == -1)
        {
            wcerr << L"Error " << tet.get_errnum()
                << L" in " << tet.get_apiname() << L"(): "
                << tet.get_errmsg() << endl;
            return 2;
        }

        /* Get number of pages in the document */
        int const n_pages = (int) tet.pcos_get_number(doc, L"length:pages");

        /* Loop over all pages and extract images */
        for (int pageno = 1; pageno <= n_pages; ++pageno)
        {
            int const page = tet.open_page(doc, pageno, pageoptlist);

            if (page == -1)
            {
                wcerr << L"Error " << tet.get_errnum()
                    << L" in " << tet.get_apiname()
                    << L"(): " << tet.get_errmsg() << endl;
                continue;                        /* process next page */
            }

            /* Retrieve all images on the page */
            const TET_image_info *ti;
            int imagecount = 0;

            while ((ti = tet.get_image_info(page)) != 0)
            {
                imagecount++;

                /* Report image details: pixel geometry, color space, etc. */
                report_image_info(tet, doc, ti->imageid);

                /* Report placement geometry */
                wcout << L"  placed on page " << pageno << L" at position ("
                        << ti->x << L", " << ti->y << L"): "
                        << (int) ti->width << L"x" << (int) ti->height
                        << L"pt, alpha=" << ti->alpha
                        << L", beta=" << ti->beta << endl;

                /* Write image data to file */
                wostringstream imageoptlist;
                imageoptlist << L"filename={" << woutfilebase
                        << L"_p" << pageno << L"_" << imagecount
                        << L"_I" << ti->imageid << L"}";

                if (tet.write_image_file(doc, ti->imageid, imageoptlist.str())
                    == -1)
                {
                    wcerr << L"Error " << tet.get_errnum()
                            << L" in " << tet.get_apiname()
                            << L"(): " << tet.get_errmsg() << endl;
                    continue;                  /* process next image */
                }

                /* Check whether the image has a mask attached... */
                wostringstream pcos_path;
                pcos_path << L"images[" << ti->imageid << L"]/maskid";

                int const maskid =
                        (int) tet.pcos_get_number(doc, pcos_path.str());

                /* ...and retrieve it if present */
                if (maskid != -1)
                {
                    wcout << L"  masked with ";

                    report_image_info(tet, doc, maskid);

                    imageoptlist.str(L"");
                    imageoptlist << L"filename={" << woutfilebase
                                << L"_p" << pageno << L"_" << imagecount
                                << L"_I" << ti->imageid
                                << L"_mask_I" << maskid << L"}";

                    if (tet.write_image_file(doc, maskid, imageoptlist.str())
                                                            == -1)
                    {
                        wcerr << endl
                            << L"Error " << tet.get_errnum()
                            << L" in " << tet.get_apiname()
                            << L"() for mask image: " << tet.get_errmsg()
                            << endl;
                    }
                }
            }

            if (tet.get_errnum() != 0)
            {
                wcerr << L"Error " << tet.get_errnum()
                    << L" in " << tet.get_apiname()
                    << L"() on page " << pageno
                    << L": " << tet.get_errmsg() << endl;
            }

            tet.close_page(page);
        }

        tet.close_document(doc);
    }
    catch (TET::Exception &ex)
    {
        if (pageno == 0)
            wcerr << L"Error " << ex.get_errnum()
                << L" in " << ex.get_apiname()
                << L"(): " << ex.get_errmsg() << endl;
        else
            wcerr << L"Error " << ex.get_errnum()
                << L" in " << ex.get_apiname()
                << L"() on page " << pageno
                << L": " << ex.get_errmsg() << endl;
    }

    return 0;
}

namespace
{

/* Print the following information for each image:
 * - pCOS id (required for indexing the images[] array)
 * - pixel size of the underlying PDF Image XObject
 * - number of components, bits per component, and colorspace
 * - mergetype if different from "normal", i.e. "artificial" (=merged)
 *   or "consumed"
 * - "stencilmask" property, i.e. /ImageMask in PDF
 */
void
report_image_info(TET& tet, int doc, int imageid)
{
    wostringstream pcos_path;

    pcos_path << L"images[" << imageid << L"]/Width";
    int const width = (int) tet.pcos_get_number(doc, pcos_path.str());

    pcos_path.str(L"");
    pcos_path << L"images[" << imageid << L"]/Height";
    int const height = (int) tet.pcos_get_number(doc, pcos_path.str());

    pcos_path.str(L"");
    pcos_path << L"images[" << imageid << L"]/bpc";
    int const bpc = (int) tet.pcos_get_number(doc, pcos_path.str());

    pcos_path.str(L"");
    pcos_path << L"images[" << imageid << L"]/colorspaceid";
    int const cs = (int) tet.pcos_get_number(doc, pcos_path.str());

    pcos_path.str(L"");
    pcos_path << L"colorspaces[" << cs << L"]/components";
    int const components = (int) tet.pcos_get_number(doc, pcos_path.str());

    wcout << L"image " << imageid << L": " << width << L"x" << height
            << L"pixel, ";

    pcos_path.str(L"");
    pcos_path << L"colorspaces[" << cs << L"]/name";
    wstring const csname = tet.pcos_get_string(doc, pcos_path.str());
    wcout << components << L"x" << bpc << L" bit " << csname;

    if (csname == L"Indexed")
    {
        pcos_path.str(L"");
        pcos_path << L"colorspaces[" << cs << L"]/baseid";
        int const basecs = (int) tet.pcos_get_number(doc, pcos_path.str());

        pcos_path.str(L"");
        pcos_path << L"colorspaces[" << basecs << L"]/name";
        wstring const basecsname = tet.pcos_get_string(doc, pcos_path.str());
        wcout << L" " << basecsname;
    }

    /* Check whether the image has been created by merging smaller images */
    pcos_path.str(L"");
    pcos_path << L"images[" << imageid << L"]/mergetype";
    int const mergetype = (int) tet.pcos_get_number(doc, pcos_path.str());
    if (mergetype == 1)
        wcout << L", mergetype=artificial";

    pcos_path.str(L"");
    pcos_path << L"images[" << imageid << L"]/stencilmask";
    int const stencilmask = (int) tet.pcos_get_number(doc, pcos_path.str());
    if (stencilmask != 0)
        wcout << L", used as stencil mask";

    wcout << endl;
}

/*
 * Get a wstring for the given string.
 */
wstring get_wstring(const TET& tet, const string& utf8_string)
{
    const size_t size = sizeof(wstring::value_type);
    string wide_string;

    switch (size)
    {
    case 2:
        wide_string = tet.convert_to_unicode(L"auto", utf8_string,
                                                L"outputformat=utf16");
        break;

    case 4:
        wide_string = tet.convert_to_unicode(L"auto", utf8_string,
                                                L"outputformat=utf32");
        break;

    default:
        throw std::logic_error("Unsupported wchar_t size");
    }

    return wstring(reinterpret_cast<const wchar_t *>(wide_string.data()),
            wide_string.length() / size);
}

} // end of anonymous namespace
