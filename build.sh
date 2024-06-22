#!/bin/bash
outfile=${PWD##*/}.pdf
rm $outfile
pdfunite $(ls -vr seg*.pdf) $outfile

