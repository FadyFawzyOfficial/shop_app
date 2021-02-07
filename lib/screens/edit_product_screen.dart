import 'package:flutter/material.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();

  // You need to dispose your own focus nodes in dispose() method, to be sure
  // that you clear (free up) up memory which they occupy & avoid memory leaks.
  @override
  void dispose() {
    super.dispose();
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                textInputAction: TextInputAction.next,
                // No need for next argument (onFieldSubmitted) to move to the
                // next TextFormField in the Form. [1. Comment and Try]
                // You just need to add the next Field and it will get focus.
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_priceFocusNode);
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                // No need for next argument (focusNode) to get focus in here.
                // Automatically focus in when the previous TextFormField hit
                // Next button in soft keyboard. [1. Comment and Try]
                focusNode: _priceFocusNode,
                // No need for next argument (onFieldSubmitted) to move to the
                // next TextFormField in the Form. [1. Comment and Try]
                // You just need to add the next Field and it will get focus.
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_descriptionFocusNode);
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                // No need for next argument (focusNode) to get focus in here.
                // Automatically focus in when the previous TextFormField hit
                // Next button in soft keyboard. [1. Comment and Try]
                focusNode: _descriptionFocusNode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
