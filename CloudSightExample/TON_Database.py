#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Nov 26 13:40:24 2018

@author: Shruti
"""

import json
import pandas as pd
import requests
from flask import Flask, request, jsonify
#from flask_ngrok import run_with_ngrok


app = Flask(__name__)
#run_with_ngrok(app)
#df = pd.read_excel("TONDatabase.xlsx", "Sheet1", keep_default_na= False, na_values=[""])

#df.columns
"""
@app.route("/")
def hello()
    return "Hello World!"

if __name__ == '__main__':
    app.run()
"""

"""
@app.route('/', methods = ['POST'])
def get_messages():
    json = request.get_json()
    classify(json['apiresult'])
    return '{ Success }'
"""

if __name__ == '__main__':
    app.run()

@app.route("/", methods = ['POST'])
def get_messages():
    json = request.get_json()
    lookup(json['apiresult'])
    return jsonify({'bin':lookup(json['apiresult'])})


ton_data_file = 'TONDatabase.xlsx'
ton = pd.read_excel(ton_data_file,
					sheet_name=0,
					header=0,
					#index_col=False,
					keep_default_na=False)


#word =
flag = "False"

def lookup(word):
    if ton['Recycling'].str.contains(word).any():
        flag = "True"
        return "Recycling"
    elif ton['Compost'].str.contains(word).any():
        flag = "True"
        return "Compost"
    #elif ton['Garbage'].str.contains(word).any():
        #flag = True
        #print("Garbage")

    if flag == "False":
        bow = word.split(" ")
        n = len(bow)
        for i in range(0,n):
            for j in range(i,n):
                word = bow[j] + " "
            word = word.rstrip()
        lookup(word)



