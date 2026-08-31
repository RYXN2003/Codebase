import 'package:codebase/Constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'message.dart';

Widget createChatSection(List<Message> messages) {
  return Expanded(
            child: Container(
              color: mainGrey,
              child: GroupedListView<Message, DateTime>(
                reverse: false,
                order: GroupedListOrder.ASC,
                elements: messages,
                groupBy: (message) => DateTime(
                  message.date.year,
                  message.date.month,
                  message.date.day
                ),
                groupHeaderBuilder: (Message message) => SizedBox(
                  height: 40,
                  child: Column(
                    children: [
                      const Divider(
                        color: Colors.white,
                        thickness: 0.2,
                      ),
                      Text(
                        DateFormat.yMMMd().format(message.date),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                ), 
                itemBuilder: (context, Message message) {
                  return Align(
                    alignment: message.isSentByMe 
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.6),
                      child: Column(
                        children: [
                          // Message
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)
                            ),
                            elevation: 8,
                            color: message.isSentByMe ? Colors.blue : secondaryGrey,
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Text(
                                message.text,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          // Time
                          Text(message.time.toString(),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12
                          ),)
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          );
}