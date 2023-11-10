#!/bin/bash
cd web && docker build . -t app/web && docker run -d -p 8000:8000 app/web
