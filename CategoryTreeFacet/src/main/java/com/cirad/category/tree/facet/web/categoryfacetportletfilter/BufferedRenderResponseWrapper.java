package com.cirad.category.tree.facet.web.categoryfacetportletfilter;

import javax.portlet.RenderResponse;
import javax.portlet.filter.RenderResponseWrapper;
import java.io.CharArrayWriter;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;

public class BufferedRenderResponseWrapper extends RenderResponseWrapper {

    BufferedRenderResponseWrapper(RenderResponse response) {
        super(response);

        charWriter = new CharArrayWriter();
    }

    public OutputStream getOutputStream() throws IOException {
        if (getWriterCalled) {
            throw new IllegalStateException("getWriter already called");
        }

        getOutputStreamCalled = true;

        return super.getPortletOutputStream();
    }

    public PrintWriter getWriter() throws IOException {
        if (writer != null) {
            return writer;
        }

        if (getOutputStreamCalled) {
            throw new IllegalStateException("getOutputStream already called");
        }

        getWriterCalled = true;

        writer = new PrintWriter(charWriter);

        return writer;
    }

    public String toString() {
        String s = null;

        if (writer != null) {
            s = charWriter.toString();
        }

        return s;
    }

    private CharArrayWriter charWriter;
    private PrintWriter writer;
    private boolean getOutputStreamCalled;
    private boolean getWriterCalled;

}