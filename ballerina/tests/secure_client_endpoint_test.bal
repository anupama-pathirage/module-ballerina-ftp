// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
import ballerina/test;
import ballerina/lang.'string as strings;
import ballerina/log;

@test:Config{
    dependsOn: [testRemoveDirectory]
}
public function testSecureGetFileContent() returns error? {
    stream<byte[] & readonly, io:Error?>|Error str = sftpClientEp->get("/file2.txt", 11);
    if (str is stream<byte[] & readonly, io:Error?>) {
        record {|byte[] value;|}|error? arr1 = trap str.next();
        if (arr1 is record {|byte[] value;|}) {
            string fileContent = check strings:fromBytes(arr1.value);
            test:assertEquals(fileContent, "Put content",
                msg = "Found unexpected content from secure `get` operation");
            record {|byte[] value;|}|error? arr2 = trap str.next();
            test:assertTrue(arr2 is (),
                msg = "Unexpected content from 2nd `next` method of `get` operation after `put` operation");
        } else {
            if arr1 is error {
                test:assertFail(msg = "Error while `next` operation " + arr1.message());
            }
            test:assertFail(msg = "Found unexpected arr1 output type");
        }
        io:Error? closeResult = str.close();
        if closeResult is io:Error {
            test:assertFail(msg = "Error while closing stream in `get` operation." + closeResult.message());
        }
    } else {
       test:assertFail(msg = "Found unexpected response type" + str.message());
    }
}

@test:Config{
    dependsOn: [testSecureGetFileContent]
}
public function testSecureConnectWithWrongPassword() returns error? {

    ClientConfiguration incorrectSftpConfig = {
        protocol: SFTP,
        host: "127.0.0.1",
        port: 21213,
        auth: {
            credentials: {username: "wso2", password: "wrongPassword"},
            privateKey: {
                path: "tests/resources/sftp.private.key",
                password: "changeit"
            }
        }
    };

    Client|Error incorrectSftpClientEp = new(incorrectSftpConfig);
    if incorrectSftpClientEp is Error {
        test:assertTrue(incorrectSftpClientEp.message().startsWith("Error while connecting to the FTP server with URL: "),
            msg = "Unexpected error during the SFTP client initialization with wrong password. " + incorrectSftpClientEp.message());
    } else {
        test:assertFail(msg = "Found a non-error response while initializing SFTP client with wrong password.");
    }
}

@test:Config{
    dependsOn: [testSecureConnectWithWrongPassword]
}
public function testSecureConnectWithWrongKey() returns error? {

    ClientConfiguration incorrectSftpConfig = {
        protocol: SFTP,
        host: "127.0.0.1",
        port: 21213,
        auth: {
            credentials: {username: "wso2", password: "wso2123"},
            privateKey: {
                path: "tests/resources/sftp.wrong.private.key",
                password: "changeit"
            }
        }
    };

    Client|Error incorrectSftpClientEp = new(incorrectSftpConfig);
    if incorrectSftpClientEp is Error {
        test:assertTrue(incorrectSftpClientEp.message().startsWith("Error while connecting to the FTP server with URL: "),
            msg = "Unexpected error during the SFTP client initialization with an invalid key. " + incorrectSftpClientEp.message());
    } else {
        test:assertFail(msg = "Found a non-error response while initializing SFTP client with an invalid key.");
    }
}

@test:Config{
    dependsOn: [testSecureGetFileContent]
}
public function testSecurePutFileContent() returns error? {
    stream<io:Block, io:Error?> bStream = check io:fileReadBlocksAsStream(putFilePath, 5);

    Error? response = sftpClientEp->put("/tempFile1.txt", bStream);
    if response is Error {
        test:assertFail(msg = "Error in secure `put` operation" + response.message());
    }
    log:printInfo("Executed secure `put` operation");

    stream<byte[] & readonly, io:Error?>|Error str = sftpClientEp->get("/tempFile1.txt", 11);
    if (str is stream<byte[] & readonly, io:Error?>) {
        record {|byte[] value;|}|io:Error? arr1 = str.next();
        if (arr1 is record {|byte[] value;|}) {
            string fileContent = check strings:fromBytes(arr1.value);
            test:assertEquals(fileContent, "Put content",
                msg = "Found unexpected content from secure `get` operation after `put` operation");
            record {|byte[] value;|}|io:Error? arr2 = str.next();
            test:assertTrue(arr2 is (),
                msg = "Unexpected content from 2nd `next` method of secure `get` operation after `put` operation");
        } else {
            test:assertFail(msg = "Found unexpected arr1 output type");
        }
        io:Error? closeResult = str.close();
        if closeResult is io:Error {
            test:assertFail(msg = "Error while closing stream in secure `get` operation." + closeResult.message());
        }
    } else {
       test:assertFail(msg = "Found unexpected response type" + str.message());
    }
}

@test:Config{
    dependsOn: [testSecurePutFileContent]
}
public function testSecureDeleteFileContent() returns error? {

    Error? response = sftpClientEp->delete("/tempFile1.txt");
    if response is Error {
        test:assertFail(msg = "Error in secure `delete` operation" + response.message());
    }
    log:printInfo("Executed secure `delete` operation");

    stream<byte[] & readonly, io:Error?>|Error str = sftpClientEp->get("/tempFile1.txt", 61);
    if (str is stream<byte[] & readonly, io:Error?>) {
        (record {|byte[] value;|}|io:Error)|error? arr1 = trap str.next();
        if (arr1 is record {|byte[] value;|}) {
            string fileContent = check strings:fromBytes(arr1.value);
            test:assertNotEquals(fileContent, "Put content",
                msg = "File was not deleted with secure `delete` operation");
        } else if arr1 is io:Error {
            test:assertFail(msg = "I/O Error during secure `get` operation after secure `delete` operation" + arr1.message());
        } else if arr1 is error {
            test:assertFail(msg = "Found unexpected output type " + arr1.message());
        } else {
            test:assertFail(msg = "Nil type during secure `get` operation after secure `delete` operation");
        }
        io:Error? closeResult = str.close();
        if closeResult is io:Error {
            test:assertFail(msg = "Error while closing the stream in secure `get` operation." + closeResult.message());
        }
    } else {
        test:assertEquals(str.message(),
            "Failed to read file: sftp://wso2:wso2123@127.0.0.1:21213/tempFile1.txt not found",
            msg = "Correct error is not given when trying to get a non-existing file.");
    }
}
