// --- LICENSE ---
/**
Copyright 2026 CouchSurfing International Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
// --- LICENSE ---

import 'package:analyzer/dart/element/type.dart';
import 'package:bloc_enhancer/bloc_enhancer.dart';
import 'package:source_gen/source_gen.dart' show TypeChecker;

const _supportedBlocPackages = {'bloc', 'streamless_bloc'};

bool isBlocSupertype(InterfaceType supertype) {
  if (supertype.element.name != 'Bloc') {
    return false;
  }
  if (supertype.typeArguments.length != 2) {
    return false;
  }

  final uri = supertype.element.library.uri.toString();
  return _supportedBlocPackages.any(
    (packageName) => uri.startsWith('package:$packageName/'),
  );
}

bool isSupportedBlocType(DartType type) {
  if (type is! InterfaceType) {
    return false;
  }

  return type.allSupertypes.any(isBlocSupertype);
}

InterfaceType findBlocSupertype(DartType type) {
  if (type is! InterfaceType) {
    throw StateError('Expected a class type extending Bloc');
  }

  return type.allSupertypes.firstWhere(isBlocSupertype);
}

final TypeChecker enhanceChecker = TypeChecker.typeNamed(
  Enhance,
  inPackage: 'bloc_enhancer',
  inSdk: false,
);

final TypeChecker ignoreChecker = TypeChecker.typeNamed(
  Ignore,
  inPackage: 'bloc_enhancer',
  inSdk: false,
);

final TypeChecker createFactoryChecker = TypeChecker.typeNamed(
  CreateFactory,
  inPackage: 'bloc_enhancer',
  inSdk: false,
);
