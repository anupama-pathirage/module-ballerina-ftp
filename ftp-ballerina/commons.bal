// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/io;

# Represents the set of protocols supported by the FTP listener and client
public type Protocol "ftp"|"sftp";

# Underlying communication happens using FTP
public const FTP = "ftp";
# Underlying communication happens using SFTP
public const SFTP = "sftp";

# Configuration to connect to a trust store.
#
# + path - Path to a trust store file
# + password - Trust store password
public type TrustStore record {|
    string? path = ();
    string? password = ();
|};

# Configuration to connect to a key store.
#
# + path - Path to the key store file
# + password - Key store password
public type KeyStore record {|
    string? path = ();
    string? password = ();
|};

# Configuration to read a privte key.
#
# + path - Path to the private key file
# + password - Private key password
public type PrivateKey record {|
    string? path = ();
    string? password = ();
|};

# Basic Auth related configurations.
#
# + username - Username of the user
# + password - Password of the user
public type BasicAuth record {|
    string username;
    string password;
|};

# Configurations for facilitating secure communication with a remote
# FTP server.
#
# + basicAuth - Username and password to be used
# + privateKey - Private key to be used
public type AuthConfiguration record {|
    BasicAuth? basicAuth = ();
    PrivateKey? privateKey = ();
|};

# Configuration for the input given for `put` and `append` operations of
# the FTP module.
#
# + filePath - Path of the file to be created or appended
# + isFile - `true` if the input type is a file
# + fileContent - The content read from the input file, if the input is a file
# + textContent - The input content, for other input types
# + compressInput - If true, input will be compressed before uploading
public type InputContent record{|
    string filePath;
    boolean isFile = false;
    stream<byte[] & readonly, io:Error?>? fileContent = ();
    string? textContent = ();
    boolean compressInput = false;
|};
